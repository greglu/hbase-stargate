module HBase
  module Request
    class TableRequest < BasicRequest
      attr_reader :name

      def initialize(url, name)
      end
    end
  end
end
