class HTTPBench
  Result = Struct.new :url, :connect_sec, :get_sec, :status
  class Result
    def to_json(*args)
      { url: url,
        connect_ms: (connect_sec * 1000).to_i,
        get_ms: (get_sec * 1000).to_i,
        status: status }.to_json(*args)
    end
  end

  Error = Struct.new :url, :exception
  class Error
    def to_json(*args)
      { url: url,
        error: exception.inspect }.to_json(*args)
    end
  end
end
