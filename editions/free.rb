# frozen_string_literal: true

require './editions/morning'

module Editions
  class Free < Morning
    def elements
      [
        title,
        Templates::Element.spacer('20px'),
        sp500_futures,
        nasdaq_futures,
        dowjones_futures,
        Templates::Element.divider,
        generic_title('Performance'),
        sp500_performance,
        nasdaq_performance,
        dowjones_performance,
        Templates::Element.spacer('20px')
      ]
    end

    def subscribers_group_id
      ENV['FREE_GROUP']
    end
  end
end
