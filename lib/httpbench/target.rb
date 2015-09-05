module HTTPBench
  Target = Struct.new :url
  class Target
    # Latency, in ms
    attr_accessor :latency

    def self.benchmark(url)
      new(url).tap(&:execute)
    end

    def execute
      self.latency = url.end_with?('slow') ? 1010 : 10
    end
  end
end
