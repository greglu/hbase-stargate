begin
  require 'yajl/json_gem'
rescue LoadError => e
  begin
    require 'json'
  rescue LoadError => e
    puts "[hbase-stargate] json is required. Install it with 'gem install json' (or json-jruby for JRuby)"
    raise e
  end
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
