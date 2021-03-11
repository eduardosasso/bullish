# frozen_string_literal: true

require './editions/edition'
require './services/futures'

module Editions
  class Morning < Edition
    def subject
      @subject ||= begin
         sample = futures.to_a.sample(1).to_h
         key = sample.keys.first
         value = sample.values.first

         down = %w[down negative ↓].sample
         up = %w[up positive ↑].sample

         preposition = ['is trending', 'is'].sample
         premarket = ['premarket', 'pre-market', 'early trading', 'market futures'].sample

         up_down = value.start_with?(Templates::Element::MINUS) ? down : up

         "#{Services::Ticker::ALIAS[key.to_sym]} #{preposition} #{up_down} in " + premarket
       end
    end

    def preheader
      field = %i[symbol name].sample

      stocks = Services::Trending.new.stocks.sample(2).map(&field).join(' and ')

      this_morning = ['this morning', 'this ' + day_of_the_week.to_s, 'today'].sample

      stocks + ' are trending ' + this_morning + '...'
    end

    def name
      'Morning edition'
    end

    def elements
      [
        generic_title('Futures', 'Pre-Market Data', formatted_time),
        Templates::Element.spacer('20px'),
        item_futures(:sp500),
        item_futures(:nasdaq),
        item_futures(:dowjones),
        Templates::Element.divider,
        todays_elements
      ]
    end

    def monday_elements
      [
        index_summary,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        trending(5)
      ]
    end

    def tuesday_elements
      [
        index_performance,
        gold_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        trending(3)
      ]
    end

    def wednesday_elements
      [
        index_performance,
        treasury_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        trending(3)
      ]
    end

    def thursday_elements
      [
        index_performance,
        russell2000_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        trending(3)
      ]
    end

    def friday_elements
      [
        trending(5),
        Templates::Element.divider,
        crypto
      ]
    end

    def subscribers_group_id
      Services::Config.premium_group
    end
  end
end
