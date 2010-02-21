module Stargate
  module Response
    class TableResponse < BasicResponse

      def initialize(raw_data, method)
        @method = method
        super(raw_data)
      end

      def parse_content(raw_data)
        case @method
        when :show
          table = JSON.parse(raw_data)

          column_families = []
          table["ColumnSchema"].each do |column|
            resolved_attributes = {}
            column.each do |k,v|
              if Model::ColumnDescriptor::AVAILABLE_OPTS.has_value? k
                resolved_attributes[Model::ColumnDescriptor::AVAILABLE_OPTS.index(k)] = v
              end
            end
            column_families << Model::ColumnDescriptor.new(resolved_attributes)
          end

          Model::TableDescriptor.new(:name => table["name"], :column_families => column_families)

        when :delete
          verify_success(raw_data)

        when :regions
          regions = JSON.parse(raw_data)

          regions["Region"].collect do |region|
            resolved_attributes = {}
            region.each do |k,v|
              if Model::Region::AVAILABLE_OPTS.has_value? k
                resolved_attributes[Model::Region::AVAILABLE_OPTS.index(k)] = v
              end
            end
            Model::Region.new(resolved_attributes)
          end
        end
      end

    end
  end
end
