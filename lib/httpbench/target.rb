require 'benchmark'
require 'forwardable'
require 'uri'

class HTTPBench
  Target = Struct.new :url, :net
  Result = Struct.new :url, :connect_sec, :get_sec, :status

  class Target
    extend Forwardable
    def_delegators :uri, :host, :port

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
    end

    private

    def connect(http = nil)
      [bm { http = net.start(host, port) },
       http]
    end

    def get(http, res = nil)
      [bm { res = http.get uri.path },
       res.code]
    end

    def uri
      URI.parse url
    end

    def bm(&blk)
      Benchmark.measure do
        blk.call
      end.real
    end
  end
end
