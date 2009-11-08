module HBase
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
          doc = JSON.parse(raw_data)
          rows = doc["Row"]

          model_rows = []
          rows.each do |row|
            rname = row["key"].strip.unpack("m").first
            count = row["Cell"].size
            columns = []

            row["Cell"].each do |col|
              name = col["column"].strip.unpack('m').first
              value = col["$"].strip.unpack('m').first rescue nil
              timestamp = col["timestamp"].to_i

              columns << HBase::Model::Column.new(  :name => name,
                                                    :value => value,
                                                    :timestamp => timestamp)
            end

            model_rows << HBase::Model::Row.new(:name => rname, :total_count => count, :columns => columns)
          end

          model_rows
        when :create_row
          verify_success(raw_data)
        when :delete_row
          verify_success(raw_data)
        else
          puts "method '#{@method}' not supported yet"
        end
      end
    end
  end
end
