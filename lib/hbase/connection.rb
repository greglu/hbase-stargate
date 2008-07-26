require 'net/http'

module HBase
  class Connection
    attr_reader :url, :connection

    def initialize(url = "http://localhost:60010/api", opts = {})
      @url = URI.parse(url)
      unless @url.kind_of? URI::HTTP
        raise "invalid http url: #{url}"
      end

      # Not actually opening the connection yet, just setting up the persistent connection.
      @connection = Net::HTTP.new(@url.host, @url.port)
      @connection.read_timeout = opts[:timeout] if opts[:timeout]
    end
  end
end
