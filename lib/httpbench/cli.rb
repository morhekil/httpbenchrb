require 'json'

class HTTPBench
  class CLI
    def run
      puts JSON.pretty_generate HTTPBench.new(lines).execute
    end

    private

    def lines
      IO.readlines(path).map(&:strip)
    end

    def path
      File.expand_path(ARGV.first)
    end
  end
end
