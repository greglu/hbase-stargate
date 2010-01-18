require 'json'

module Stargate
  module Response
    class BasicResponse

      def initialize(raw_data)
        @raw_data = raw_data
      end

      def parse
        parse_content @raw_data
      end

      def verify_success(response)
        case response
        when Net::HTTPSuccess
          true
        else
          false
        end
      end
    end
  end
end
