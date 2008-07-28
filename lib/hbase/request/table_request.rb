module HBase
  module Request
    class TableRequest < BasicRequest
      attr_reader :name
      attr_reader :body

      def initialize(name)
        super("/#{name}")
      end

      def show
        self
      end

      def regions(start_row = nil, end_row = nil)
        @path << "/regions"
        self
      end
    end
  end
end
