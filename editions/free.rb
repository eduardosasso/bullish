# frozen_string_literal: true

require './editions/morning'

module Editions
  class Free < Morning
    def elements
      [
        main_title('Stock Futures Premarket Data'),
        Templates::Element.spacer('20px'),
        item_futures(:sp500),
        item_futures(:nasdaq),
        item_futures(:dowjones),
        Templates::Element.divider,
        generic_title('Performance'),
        sp500_performance,
        nasdaq_performance,
        dowjones_performance,
        Templates::Element.spacer('20px')
      ]
    end

    def subscribers_group_id
      Services::Config.free_group_id
    end
  end
end
