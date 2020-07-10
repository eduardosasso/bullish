# frozen_string_literal: true

require './editions/morning'
require './editions/afternoon'

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
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        subscribe_premium
      ]
    end

    def subscribe_premium
      headline = [
        'More? Sign up for Bullish Pro',
        'More insights like that?',
        'More like that? Go PRO',
        'Paid feature. See more...',
        'Premium sneak peak ☝️',
        'Know more. Get Pro',
        'That and lots more ✨',
        'Don''t miss out'
      ].sample

      label = [
        'Subscribe now',
        'Give it a try',
        'Try for $4.99/mo',
        'Proceed to checkout',
        'Sign up',
        'Join now',
        'Go premium',
        'Get instant access',
        'Yes, sign me up!',
        'Yes! I want in ',
        'Join the Pros',
        'Become a PRO',
        'Get it now',
        'Upgrade'
      ].sample

      premium_widget = [
        'free_trending',
        'crypto',
        'world',
        'sector_summary',
        'index_summary',
        # 'top_gainers_losers_performance',
        'top_gainers_losers',
        'world_futures'
      ].sample

      subtitle = [
        'Sneak peak',
        'Freebie',
        'Free snippet',
        'Free sample'
      ].sample

      [
        generic_title('Premium only', subtitle),
        Templates::Element.divider,
        send(premium_widget),
        Templates::Element.subscribe_premium(nil, label)
      ]
    end

    def free_trending
      trending(2)
    end

    def subscribers_group_id
      Services::Config.free_group_id
    end
  end
end
