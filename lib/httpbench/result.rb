class HTTPBench
  # Result of a successful measurement - its url, connect/read latency
  # in ms, and http response status
  Result = Struct.new :url, :connect_sec, :read_sec, :status do
    def to_json(*args)
      { url: url,
        connect_ms: (connect_sec * 1000).to_i,
        read_ms: (read_sec * 1000).to_i,
        status: status }.to_json(*args)
    end
  end

  # Errored measurement attempt - url that triggered the error,
  # and the raw exception object itself
  Error = Struct.new :url, :exception do
    def to_json(*args)
      { url: url,
        error: exception.inspect }.to_json(*args)
    end
  end
end
