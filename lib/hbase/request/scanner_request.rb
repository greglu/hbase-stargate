module HBase
  module Request
    class ScannerRequest < BasicRequest
      attr_reader :table_name

      def initialize(table_name)
        @table_name = CGI.escape(table_name)
        path = "/#{@table_name}/scanner"
        super(path)
      end

      def open(columns, start_row = nil, end_row = nil, timestamp = nil)
        search = []
        if columns.is_a? String
          search << "column=#{columns}"
        elsif columns.is_a? Array
          search << columns.collect { |col| "column=#{col}" }.join("&")
        else
          raise StandardError, "Only string or array type allowed for columns attr."
        end

        search << "start_row=#{CGI.escape(start_row)}" if start_row
        search << "end_row=#{CGI.escape(end_row)}" if end_row
        search << "timestamp=#{CGI.escape(timestamp)}" if timestamp

        @path << "?" << search.join('&')
      end

      def get_rows(scanner_id, limit = 1)
        @path << "/#{scanner_id}?limit=#{limit}"
      end

      def close(scanner_id)
        @path << "/#{scanner_id}"
      end
    end
  end
end
