module Stargate
  module Response
    class RowResponse < BasicResponse
      attr_reader :method

      def initialize(raw_data, method)
        @method = method
        super(raw_data)
      end

      def parse_content(raw_data)
        case @method
        when :show_row
          doc = Yajl::Parser.parse(raw_data)
          rows = doc["Row"]

          model_rows = []
          rows.each do |row|
            rname = Base64.decode64(row["key"])
            count = row["Cell"].size
            columns_map = {}

            row["Cell"].each do |col|
              name = Base64.decode64(col["column"])
              value = Base64.decode64(col["$"])
              timestamp = col["timestamp"].to_i
              column = Stargate::Model::Column.new(:name => name, :value => value, :timestamp => timestamp)

              if columns_map.has_key?(name)
                columns_map[name].versions << column
              else
                columns_map[name] = column
              end
            end

            model_rows << Stargate::Model::Row.new(:name => rname, :total_count => count, :columns_map => columns_map)
          end

          model_rows
        when :create_row, :delete_row
          case raw_data.status
          when 404, 500
            raise raw_data.status_line
          else
            verify_success(raw_data)
          end
        else
          puts "method '#{@method}' not supported yet"
        end
      end
    end
  end
end
