module HBase
  module Request
    class RowRequest < BasicRequest
      attr_reader :table_name
      attr_reader :name
      attr_reader :timestamp

      def initialize(table_name, name, timestamp)
        @table_name, @name, @timestamp = table_name, name, timestamp
        path = "/#{table_name}/row/#{name}"
        path << "/#{timestamp}" if timestamp
        super(path)
      end

      def show(columns = nil)
        if columns
          if columns.is_a? String
            columns = [columns]
          elsif columns.is_a? Array
          end
          @path << "?column=#{columns.join(';')}"
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
          @path << "?column=#{columns.join(';')}"
        end
        @path
      end
    end
  end
end
