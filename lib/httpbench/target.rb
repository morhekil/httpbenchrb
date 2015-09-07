require 'benchmark'
require 'forwardable'
require 'net/http'

class HTTPBench
  class Target
    extend Forwardable
    def_delegators :uri, :host, :port, :path, :scheme

    def self.benchmark(url, cfg)
      new(url, cfg: cfg).execute
    end

    def initialize(url, net: Net::HTTP, cfg: Config.new)
      @url = url
      @net = net
      @cfg = cfg
    end

    def execute
      ctime, http = connect
      gtime, status = get http
      Result.new @url, ctime, gtime, status
    rescue SystemCallError, Timeout::Error => err
      Error.new @url, err
    end

    private

    def connect(http = nil)
      [bm { http = @net.start(host, port, http_opts) },
       http]
    end

    def http_opts
      { use_ssl: scheme == 'https',
        read_timeout: @cfg.timeout,
        open_timeout: @cfg.timeout }
    end

    def get(http, res = nil)
      [bm { res = http.get(path) },
       res.code]
    end

    def uri
      @uri ||= URL.parse @url
    end

    def bm(&blk)
      Benchmark.measure do
        blk.call
      end.real
    end
  end
end
