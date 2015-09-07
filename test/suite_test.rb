require 'minitest/autorun'

require_relative '../lib/httpbench'

class TestBenchSuite < Minitest::Test
  Res = Struct.new :url

  def test_benchmark_of_all_targets
    target = Minitest::Mock.new
    urls = ['http://google.com',
            'http://bing.com']

    urls.each do |url|
      target.expect(:benchmark, Res.new(url)) do
        urls.delete(url) || fail("Unexpected #{url}")
      end
    end
    HTTPBench.new(urls).execute target
    target.verify
  end
end
