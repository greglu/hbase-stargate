module HBase
  module Response
    class RowResponse < BasicResponse
      def parse_content(raw_data)
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
      end
    end
  end
end
