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
      uri.scheme ||= uri.port == 443 ? 'https' : 'http'
      uri.port ||= uri.scheme == 'https' ? 443 : 80
      uri.path = '/' if uri.path.to_s.empty?
      @uri = uri.freeze
    end
  end
end
