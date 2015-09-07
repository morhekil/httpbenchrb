require 'benchmark'
require 'forwardable'
require 'net/http'

class HTTPBench
  class Target
    extend Forwardable
    def_delegators :uri, :host, :port, :path, :scheme

    BM = ->(&blk) { Benchmark.measure { blk.call }.real }

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
      [BM.call { http = @net.start(host, port, http_opts) },
       http]
    end

    def http_opts
      { use_ssl: scheme == 'https',
        read_timeout: @cfg.timeout,
        open_timeout: @cfg.timeout }
    end

    def get(http, res = nil)
      [BM.call { res = http.get(path) },
       res.code]
    end

    def uri
      @uri ||= URL.parse @url
    end
  end
end
