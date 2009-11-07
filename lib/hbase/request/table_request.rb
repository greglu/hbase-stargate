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
        @path << "/#{name}/schema"
      end

      def regions(start_row = nil, end_row = nil)
        #TODO no handle the args!
        @path << "/#{name}/regions"
      end

      def create
        @path << "/#{name}/schema"
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
        warn "[DEPRECATION] the use of the 'columns' argument is deprecated. Please use the delete method without any arguments." if columns
        @path << "/#{name}/schema"
      end
    end
  end
end
