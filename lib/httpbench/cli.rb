require 'json'
require 'optparse'

class HTTPBench
  # CLI constructs a command line interface to drive HTTPBench. It populates
  # the config file based on the command line options, and either reads a list
  # of URLs from a given file, or accepts it from standard input if no file
  # was specified
  class CLI
    def initialize
      @cfg = Config.new STDIN
    end

    def run
      Parser.new(@cfg).populate
      @cfg.write JSON.pretty_generate(benchmark)
    end

    private

    def benchmark
      HTTPBench.new(@cfg.readlines).execute config: @cfg
    end

    Parser = Struct.new :cfg
    # Parser deconstructs command line options into the provided config
    # structure
    class Parser
      extend Forwardable
      def_delegators :@opts, :on, :on_tail, :separator, :parse!

      OPTS = %i(header infile outfile threads timeout help)

      def initialize(*args)
        super(*args)
        @opts = OptionParser.new
      end

      def populate
        OPTS.each { |m| send m }
        parse! ARGV
      end

      def header
        @opts.banner = 'Usage: httpbench [options]'
        separator ''
        separator 'Options:'
      end

      def infile
        on('-i', '--infile [file]', 'file to read URLs from. If not given - '\
                                    'reads from stdin') do |f|
          cfg.infile = File.open(f)
        end
      end

      def outfile
        on('-o', '--outfile [file]', 'file to write report to. If not given - '\
                                     'writes to stdout') do |f|
          cfg.outfile = File.open(f, 'w')
        end
      end

      def threads
        on('-n', "--threads [N]", Integer,
           'number of threads to use for http checks',
           " (defaults to #{cfg.workers})") do |n|
          cfg.workers = n
        end
      end

      def timeout
        on('-t', "--timeout [N]", Integer,
           'open and read timeout for http connections',
           " (in seconds, defaults to #{cfg.timeout})") do |n|
          cfg.timeout = n
        end
      end

      def help
        on_tail '-h', '--help', 'Show this message' do
          puts @opts
          exit
        end
      end
    end
  end
end
