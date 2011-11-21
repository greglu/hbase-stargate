require 'patron'
require 'stargate/operation/meta_operation'
require 'stargate/operation/table_operation'
require 'stargate/operation/row_operation'
require 'stargate/operation/scanner_operation'

module Stargate
  class Client
    include Operation::MetaOperation
    include Operation::TableOperation
    include Operation::RowOperation
    include Operation::ScannerOperation

    attr_reader :url, :connection

    def initialize(url = "http://localhost:8080", opts = {})
      @url = URI.parse(url)
      unless @url.kind_of? URI::HTTP
        raise "invalid http url: #{url}"
      end

      @connection = Patron::Session.new
      @connection.base_url = url
      @connection.timeout = opts[:timeout] unless opts[:timeout].nil?

      # Not actually opening the connection yet, just setting up the persistent connection.
      @connection.proxy = opts[:proxy] unless opts[:proxy].nil?
    end

    def rest_get(path, options = {})
      safe_request { @connection.get(@url.path + path, {"Accept" => "application/json"}.merge(options)) }
    end

    def rest_get_response(path, options = {})
      safe_response { @connection.get(@url.path + path, {"Accept" => "application/json"}.merge(options)) }
    end

    def rest_post(path, data = nil, options = {})
      safe_request { @connection.post(@url.path + path, data, {'Content-Type' => 'text/xml'}.merge(options)) }
    end

    def rest_post_response(path, data = nil, options = {})
      safe_response { @connection.post(@url.path + path, data, {'Content-Type' => 'text/xml'}.merge(options)) }
    end

    def rest_delete(path, options = {})
      safe_request { @connection.delete(@url.path + path, options) }
    end

    def rest_delete_response(path, options = {})
      safe_response { @connection.delete(@url.path + path, options) }
    end

    def rest_put(path, data = nil, options = {})
      safe_request { @connection.put(@url.path + path, data, {'Content-Type' => 'text/xml'}.merge(options)) }
    end

    def rest_put_response(path, data = nil, options = {})
      safe_response { @connection.put(@url.path + path, data, {'Content-Type' => 'text/xml'}.merge(options)) }
    end

    private

      def safe_response(&block)
        begin
          yield
        rescue => e
          raise ConnectionNotEstablishedError, "Connection problem with HBase rest server #{@url}:\n#{e.message}"
        end
      end

      def safe_request(&block)
        response = safe_response{ yield block }

        case response.status
        when 200
          response.body
        else
          raise response.status_line
        end
      end

  end
end
