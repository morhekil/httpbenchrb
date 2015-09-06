class HTTPBench < Array
  def execute(target = Target)
    map { |url| target.benchmark(url) }
  end
end

require_relative 'httpbench/target'
