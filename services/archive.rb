# frozen_string_literal: true

require './services/s3'
require './services/log'
require './services/config'
require 'base64'
require 'date'
require './templates/element'
require 'active_support/inflector'

module Services
  class Archive
    YEAR = Time.now.strftime('%Y')
    MONTH = Time.now.strftime('%m')

    FOLDER = "#{YEAR}-#{MONTH}"
    MONTH_YEAR_FORMAT = '%B %Y'

    BUCKET = 'bullish-archive'
    YEAR_PREFIX = '20'

    def initialize(bucket = BUCKET)
      @bucket = bucket

      @bucket += '-test' if Services::Config.test? 
    end

    def upload(subject, content)
      # create friendly URL
      name = subject.parameterize.dasherize

      name = "#{FOLDER}/#{name}.html"
      tags = { subject_base64: Base64.urlsafe_encode64(subject, padding: false) }

      Services::S3.new(@bucket).upload(name: name, content: content, tags: tags)
    end

    def build_index(filename = 'index.html')
      s3 = Services::S3.new(@bucket)

      archive = s3.list({ prefix: FOLDER }).map do |file|
        next if file.key == "#{FOLDER}/index.html"

        tags = s3.tags(file.key)

        title = Base64.urlsafe_decode64(tags['subject_base64'])
        date = DateTime.parse(file.last_modified.to_s).in_time_zone('Eastern Time (US & Canada)')

        # date will format as Tuesday 15th AM
        {
          url: "/archive/#{file.key}",
          title: title,
          date: date.strftime("%p %A #{date.day.ordinalize}")
        }
      end.compact

      heading = DateTime.now.strftime(MONTH_YEAR_FORMAT)

      result = Templates::Element.render('archive', { archive: archive, heading: heading })

      # save in archive root path
      s3.upload(name: filename, content: result)

      # copy to folder so each month has an index
      s3.copy(from: filename, to: "#{FOLDER}/index.html")
    rescue StandardError => e
      Services::Log.error(e.message)
    end

    def build_directory(filename = 'index.html')
      s3 = Services::S3.new(@bucket)

      index = s3.list_folders.map do |folder|
        next unless folder.start_with?(YEAR_PREFIX)

        # format folder like 2020-08 to August 2020
        title = Date.strptime(folder, '%Y-%m').strftime(MONTH_YEAR_FORMAT)

        { url: "/archive/#{folder}", title: title }
      end.compact

      # current month points to index archive page
      index[0][:url] = '/archive'

      result = Templates::Element.render('directory', { index: index })

      # save in archive root path
      s3.upload(name: 'directory/' + filename, content: result)
    end
  rescue StandardError => e
    Services::Log.error(e.message)
  end
end
