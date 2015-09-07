class HTTPBench < Array
  Config = Struct.new :file, :workers, :timeout
  class Config
    FILE = STDIN
    WORKERS = 4
    TIMEOUT = 10

    def initialize(*args)
      super(*args)
      self.file ||= STDIN
      self.workers ||= WORKERS
      self.timeout ||= TIMEOUT
    end

    # read all lines from the file, which must be an instance of IO object
    # by the time this method is called
    def readlines
      lns = file.readlines.map(&:strip)
      file.close unless file.tty?
      lns
    end

    # runs a pool of workers, executing given block of code
    def run_pool(&block)
      (1..workers)
        .map { Thread.new(&block) }
        .each(&:join)
    end
  end

  # execute all configured running, running them on a pool of threads
  # capped at config.workers value
  def execute(target: Target, config: Config.new)
    [].tap { |res| config.run_pool { process target, res, config } }
  end

  private

  # every worker pops urls from the benchmark array, until there aren't
  # any left, and pushes the measures back into the results
  def process(target, res, config)
    loop { res.push target.benchmark(pop || break, config) }
  end
end

require_relative 'httpbench/target'
require_relative 'httpbench/result'
require_relative 'httpbench/url'
require_relative 'httpbench/cli'
