require 'minitest/autorun'

require 'webrick'
require 'uri'
require 'net/http'

require_relative '../lib/httpbench'

# disabling ABC checks, as test cases are often long, and it is ok
# rubocop:disable Metrics/AbcSize

class TestIntegration < Minitest::Test
  # HTTPMock configures WEBrick to act as a test http server
  # that can be used to run benchmarks against.
  #
  # It should be used at two endpoints:
  #   /quick - replies with OK immediately
  #   /slow  - replies with OK after 1 second delay
  class HTTPMock
    ENDPOINTS = {
      '/quick' => ->(_, res) { res.body = 'OK' },
      '/slow' => ->(_, res) { sleep(1) && res.body = 'OK' }
    }

    def initialize
      @srv = WEBrick::HTTPServer.new Port: 0, DocumentRoot: '.'
      trap('INT') { @srv.shutdown }
      ENDPOINTS.each_pair { |path, hdl| @srv.mount_proc path, &hdl }
    end

    def uri(path = nil)
      URI::HTTP.build(host: @srv.config[:ServerName],
                      port: @srv.config[:Port],
                      path: "/#{path}".gsub(%r{^//}, ''))
    end

    def start
      @pid = fork { @srv.start }
    end

    def shutdown
      Process.kill 'INT', @pid
      Process.wait @pid
    end
  end

  def setup
    @httphost = HTTPMock.new.tap(&:start)
  end

  def teardown
    @httphost.shutdown
  end

  def test_http_suite
    res = HTTPBench.new(
      %w(quick slow).map { |p| @httphost.uri(p).to_s }
    ).execute

    assert res.find { |t| t.url.end_with?('quick') }.get_sec < 1.0,
           'quick endpoint measured over 1 sec'
    assert res.find { |t| t.url.end_with?('slow') }.get_sec >= 1.0,
           'quick endpoint measured under 1 sec'
  end
end
