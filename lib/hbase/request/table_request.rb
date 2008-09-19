module HBase
  module Request
    class TableRequest < BasicRequest
      attr_reader :name
      attr_reader :body

      def initialize(name)
        super("")
        @name = CGI.escape(name) if name
      end

      def show
        @path << "/#{name}"
      end

      def regions(start_row = nil, end_row = nil)
        @path << "/#{name}/regions"
      end

      def create
        @path << "/"
      end

      def update
        @path << "/#{name}"
      end

      def enable
        @path << "/#{name}/enable"
      end

      def disable
        @path << "/#{name}/disable"
      end

      def delete(columns = nil)
        @path << "/#{name}"
        if columns
          if columns.is_a? String
            columns = [columns]
          elsif columns.is_a? Array
          else
            raise StandardError, "Only String or Array type allows for columns"
          end
          params = columns.collect { |column| "column=#{column}" }.join('%')
          @path << "?#{params}"
        end
        @path
      end
    end
  end
end
