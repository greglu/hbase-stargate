require 'rexml/document'

module HBase
  module Response
    class BasicResponse

      def initialize(raw_data)
        @raw_data = raw_data
      end

      def parse
        parse_content @raw_data
      end
    end
  end
end
