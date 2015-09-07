require 'benchmark'
require 'forwardable'
require 'net/http'

class HTTPBench
  # Target is a single benchmarking target (URL), that can be
  # benchmarked and reported on.
  #
  # Normally the benchmark should be executed via Target.benchmark
  # method call, but for finer control the caller can use a combination
  # of Target.new and Target#execute
  class Target
    extend Forwardable
    def_delegators :uri, :host, :port, :path, :scheme
    def_delegators :@cfg, :timeout

    # helper to benchmark real time of a given block
    BM = ->(&blk) { Benchmark.measure { blk.call }.real }

    def self.benchmark(url, cfg = Config.new)
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
        read_timeout: timeout,
        open_timeout: timeout }
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
