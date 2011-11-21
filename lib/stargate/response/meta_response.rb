module Stargate
  module Response
    class MetaResponse < BasicResponse
      attr_reader :method

      def initialize(raw_data, method)
        @method = method
        super(raw_data)
      end

      def parse_content(raw_data)
        case @method
        when :list_tables
          if raw_data.to_s.empty? || raw_data == "null" # "null" from json
            return []
          end

          tables = []
          doc = Yajl::Parser.parse(raw_data)

          doc["table"].each do |table|
            name = table["name"].strip rescue nil
            t = Model::TableDescriptor.new(:name => name)
            tables << t
          end

          tables
        else
            puts "method '#{@method}' not supported yet"
        end
      end
    end
  end
end
