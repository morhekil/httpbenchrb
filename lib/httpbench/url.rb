class HTTPBench
  # Heuristic URL parser, which is trying to guess and fill in
  # incomplete URLs. Defaults are:
  # * if scheme is not specified, but port set to 443 - the scheme is https,
  #   otherwise - http
  # * if port is not specified, but scheme is https - the port is 443,
  #   otherwise - 80
  # * if path is empty - use root ("/") as the path
  class URL
    extend Forwardable

    def_delegators :@uri, :host, :port, :scheme, :path

    def self.parse(url)
      url = "//#{url}" unless url =~ %r{^\w+://}
      new URI.parse url
    end

    def initialize(uri)
      @uri = uri
      guessfill
    end

    private

    def guessfill
      @uri.scheme ||= port == 443 ? 'https' : 'http'
      @uri.port ||= scheme == 'https' ? 443 : 80
      @uri.path = '/' if path.to_s.empty?
    end
  end
end
