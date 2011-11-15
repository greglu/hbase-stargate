module Stargate
  module Request
    class RowRequest < BasicRequest
      attr_reader :table_name
      attr_reader :name
      attr_reader :timestamp

      def initialize(table_name, name, timestamp = nil)
        @table_name, @name, @timestamp = CGI.escape(table_name), CGI.escape(name), timestamp
        path = "/#{@table_name}/#{@name}"
        super(path)
      end

      # def timestamp
      #   @timestamp*1000 rescue nil
      # end

      def show(columns = nil, options = {})
        @path << (columns ? "/#{pack_params(columns)}" : "/")
        @path << "/#{timestamp}" if timestamp
        @path << "?v=#{options[:version]}" if options[:version]
        @path
      end

      def create(columns = nil)
        @path << (columns ? "/#{pack_params(columns)}" : "/")
        @path << "/#{timestamp}" if timestamp
        @path
      end

      def delete(columns = nil)
        @path << (columns ? "/#{pack_params(columns)}" : "/")
        @path << "/#{timestamp}" if timestamp
        @path
      end
    end
  end
end
