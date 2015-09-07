require 'benchmark'
require 'forwardable'
# require 'uri'
require 'addressable/uri'
require 'net/http'

class HTTPBench
  Target = Struct.new :url, :net

  class Target
    extend Forwardable
    def_delegators :uri, :host

    def self.benchmark(url)
      new(url).execute
    end

    def initialize(url, net = Net::HTTP)
      super url, net
    end

    def execute
      ctime, http = connect
      gtime, status = get http
      Result.new url, ctime, gtime, status
    rescue SystemCallError, Timeout::Error => err
      Error.new url, err
    end

    private

    def connect(http = nil)
      [bm { http = net.start(host, port) },
       http]
    end

    def get(http, res = nil)
      [bm { res = http.get(path) },
       res.code]
    end

    def uri
      @uri ||= Addressable::URI.heuristic_parse url
    end

    def port
      uri.port || (uri.scheme == 'https' ? 443 : 80)
    end

    def path
      uri.path.to_s.empty? ? '/' : uri.path
    end

    def bm(&blk)
      Benchmark.measure do
        blk.call
      end.real
    end
  end
end
