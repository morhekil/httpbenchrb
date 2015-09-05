module HTTPBench
  class Suite < Array
    def execute(target = Target)
      map { |url| Target.benchmark(url) }
    end
  end
end
