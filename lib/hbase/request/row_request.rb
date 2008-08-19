module HBase
  module Request
    class RowRequest < BasicRequest
      attr_reader :table_name
      attr_reader :name
      attr_reader :timestamp

      def initialize(table_name, name, timestamp)
        @table_name, @name, @timestamp = CGI.escape(table_name), CGI.escape(name), timestamp
        path = "/#{@table_name}/row/#{@name}"
        path << "/#{@timestamp}" if timestamp
        super(path)
      end

      def show(columns = nil, version = nil)
        if columns
          if columns.is_a? String
            columns = [columns]
          elsif columns.is_a? Array
          end
          params = columns.collect { |column| "column=#{column}" }.join('&')
          @path << "?#{params}"
          @path << "&version=#{version}" if version
        end
        @path
      end

      def create
        @path
      end

      def delete(columns = nil)
        if columns
          if columns.is_a? String
            columns = [columns]
          elsif columns.is_a? Array
          end
          params = columns.collect { |column| "column=#{column}" }.join('&')
          @path << "?#{params}"
        end
        @path
      end
    end
  end
end
