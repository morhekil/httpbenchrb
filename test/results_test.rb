require 'minitest/autorun'
require 'json'

require_relative '../lib/httpbench'

class TestResultFormatting < Minitest::Test
  URL = 'http://google.com'

  def test_result_formatting
    r = HTTPBench::Result.new URL, 0.120, 1.713, 200
    expected = { url: URL,
                 connect_ms: 120,
                 get_ms: 1713,
                 status: 200 }
    assert_equal JSON.pretty_generate(expected),
                 JSON.pretty_generate(r)
  end

  def test_error_formatting
    err = RuntimeError.new 'boom'
    r = HTTPBench::Error.new URL, err

    expected = { url: URL,
                 error: err.inspect }
    assert_equal JSON.pretty_generate(expected),
                 JSON.pretty_generate(r)
  end
end
