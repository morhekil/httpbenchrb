require 'forwardable'

class HTTPBench
  extend Forwardable
  def_delegators :@targets, :map, :pop

  # default number of thread workers
  WORKERS = 4
  # default read/open timeout
  TIMEOUT = 10

  # Configuration for HTTPBench instance
  Config = Struct.new :infile, :outfile, :workers, :timeout do
    def initialize(*args)
      super(*args)
      self.infile ||= STDIN
      self.outfile ||= STDOUT
      self.workers ||= WORKERS
      self.timeout ||= TIMEOUT
    end

    # read all lines from the file, which must be an instance of IO object
    # by the time this method is called
    def readlines
      lns = infile.readlines.map(&:strip)
      infile.close unless infile.tty?
      lns
    end

    # runs a pool of workers, executing given block of code
    def run_pool(&block)
      (1..workers).map { Thread.new(&block) }.each(&:join)
    end

    # write given data back to the output file
    def write(data)
      outfile.write(data)
      outfile.close unless outfile.tty?
    end
  end

  # set up httpbench, making a copy of caller's array of targets
  # to not mess it up
  def initialize(targets = [])
    @targets = targets.dup
  end

  # execute all configured targets, running them on a pool of threads
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
