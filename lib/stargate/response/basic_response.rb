begin
  require 'yajl'
rescue LoadError => e
  puts "[hbase-stargate] yajl-ruby is required. Install it with 'gem install yajl-ruby'"
  raise e
end

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
        case response.status
        when 200
          true
        else
          false
        end
      end
    end
  end
end
