# frozen_string_literal: true

require 'minitest/autorun'
require './bullish'
require 'minitest/mock'

class BullishTest < Minitest::Test
  def setup
    ENV['TEST'] = 'true'
  end

  def test_post_retry
    email = MiniTest::Mock.new
    email.expect(:post, 'first try') { raise 'first try' }
    email.expect(:post, nil) { raise 'second try' }
    email.expect(:post, 'third try')

    bullish = MiniTest::Mock.new
    bullish.expect(:subject, 'subject')
    bullish.expect(:subject, 'subject1')
    bullish.expect(:subject, 'subject2')

    bullish.expect(:content, 'content')
    bullish.expect(:content, 'content1')
    bullish.expect(:content, 'content2')

    Email.stub(:new, email) do
      Bullish.stub(:new, bullish) do
        assert_equal('third try', Bullish.post)
      end
    end
  end

  def test_subject
    futures = MiniTest::Mock.new
    futures.expect(:pre_market, 'nasdaq_f' => '-0.83%', 'sp500_f' => '1.65%', 'dowjones_f' => '2.58%')

    Futures.stub(:new, futures) do
      subject = Bullish.new.subject
      assert_match(/Pre-Market for Nasdaq|S&P 500|Dow Jones is/, subject)
    end
  end

  def test_futures
    futures_data = File.read('./test/futures.json')

    Net::HTTP.stub(:get, futures_data) do
      assert_equal(%w[nasdaq_f sp500_f dowjones_f].sort, Bullish.new.futures.keys.sort)
    end
  end

  def test_indexes
    vars = []

    Ticker::INDEX.keys.each do |index|
      vars << Ticker::PERIOD.keys.map do |period|
        "#{index}_#{period}"
      end
    end

    performance = {
      "1D": 0.44,
      "1W": 2.5,
      "1M": -21.42,
      "3M": -24.13,
      "6M": -17.65,
      YTD: -24.55,
      "1Y": -12.16,
      "5Y": 19.26,
      "10Y": 110.86
    }

    ticker = MiniTest::Mock.new
    ticker.expect(:performance, performance)
    ticker.expect(:performance, performance)
    ticker.expect(:performance, performance)

    Ticker.stub(:new, ticker) do
      assert_equal(vars.flatten.sort, Bullish.new.indexes.keys.sort)
    end
  end
end
