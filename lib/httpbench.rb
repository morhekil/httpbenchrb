class HTTPBench < Array
  WORKERS = 4

  def execute(target = Target)
    [].tap do |res|
      (1..WORKERS).map { Thread.new { process(target, res) } }.each(&:join)
    end
  end

  private

  def process(target, res)
    loop { res.push target.benchmark(pop || break) }
  end
end

require_relative 'httpbench/target'
require_relative 'httpbench/result'
require_relative 'httpbench/url'
require_relative 'httpbench/cli'
