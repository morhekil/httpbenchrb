require 'minitest/autorun'

require_relative '../lib/httpbench'

class TestTarget < Minitest::Test
  MockResult = Struct.new :code
  MockNetHTTP = Minitest::Mock
  MockHTTPConn = Minitest::Mock

  DEFAULT_HTTP_OPTS = { use_ssl: false,
                        read_timeout: HTTPBench::Config::TIMEOUT,
                        open_timeout: HTTPBench::Config::TIMEOUT }

  def test_execute_successful_benchmark
    net = MockNetHTTP.new
    http = MockHTTPConn.new
    t = HTTPBench::Target.new 'http://google.com/search', net: net

    net.expect :start, http, ['google.com', 80, DEFAULT_HTTP_OPTS]
    http.expect :get, MockResult.new(200), ['/search']

    res = t.execute
    [net, http].each(&:verify)
    assert_kind_of HTTPBench::Result, res
  end

  def test_server_down
    net = Class.new
    def net.start(*_)
      fail Errno::ECONNREFUSED
    end

    t = HTTPBench::Target.new 'http://google.com/search', net: net
    res = t.execute
    assert_kind_of HTTPBench::Error, res
  end

  def test_with_empty_path
    net = MockNetHTTP.new
    http = MockHTTPConn.new
    t = HTTPBench::Target.new 'google.com', net: net

    net.expect :start, http, ['google.com', 80, DEFAULT_HTTP_OPTS]
    http.expect :get, MockResult.new(200), ['/']

    res = t.execute
    [net, http].each(&:verify)
    assert_kind_of HTTPBench::Result, res
  end

  def test_https_url
    net = MockNetHTTP.new
    http = MockHTTPConn.new
    t = HTTPBench::Target.new 'https://google.com', net: net

    net.expect :start, http, ['google.com', 443,
                              DEFAULT_HTTP_OPTS.merge(use_ssl: true)]
    http.expect :get, MockResult.new(200), ['/']

    res = t.execute
    [net, http].each(&:verify)
    assert_kind_of HTTPBench::Result, res
  end
end
