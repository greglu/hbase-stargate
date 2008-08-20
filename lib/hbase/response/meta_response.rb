module HBase
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
          if raw_data.blank?
            puts "There are no available tables in the HBase"
            return []
          end

          doc = REXML::Document.new(raw_data)
          entry = doc.elements["tables"]
          tables = []
          entry.elements.each("table") do |table|
            t = Model::TableDescriptor.new(:name => table.text.strip)
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
