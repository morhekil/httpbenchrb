require 'json'

class HTTPBench
  class CLI
    def run
      puts JSON.pretty_generate HTTPBench.new(lines).execute
    end

    private

    def lines
      lns = source.readlines.map(&:strip)
      source.close unless source.tty?
      lns
    end

    def source
      @src = ARGV.first ? File.open(File.expand_path(ARGV.first)) : STDIN
    end
  end
end
