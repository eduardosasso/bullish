require './test/test_helper'
require './services/popup'

module Services
  class PopupTest < Minitest::Test
    def test_inject
      html = '<html><head><style>background: red;</style></head><body>Hi</body></html'
      popup = Services::Popup.new(html)

      html = popup.inject

      # test if snippet is last item before closing head tag
      assert_match(/style\>\n<\!-\- MailerLite Universal/, html)
    end
  end
end
