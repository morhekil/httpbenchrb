require 'minitest/autorun'

require_relative '../lib/httpbench'

class TestTarget < Minitest::Test
  MockResult = Struct.new :code
  MockNetHTTP = Minitest::Mock
  MockHTTPConn = Minitest::Mock

  def test_execute_successful_benchmark
    net = MockNetHTTP.new
    http = MockHTTPConn.new
    t = HTTPBench::Target.new 'http://google.com/search', net

    net.expect :start, http, ['google.com', 80]
    http.expect :get, MockResult.new(200), ['/search']

    res = t.execute
    [net, http].each(&:verify)
    assert_kind_of HTTPBench::Result, res
  end
end
