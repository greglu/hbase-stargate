module HBase
  module Response
    class RowResponse < BasicResponse
      def parse_content(raw_data)
        doc = REXML::Document.new(raw_data)
        row = doc.elements["row"]
        columns = []
        row.elements.each("column") do |col|
          name = col.elements["name"].text.strip.unpack("m").first
          value = col.elements["value"].text.strip.unpack("m").first
          columns << Model::Column.new(:name => name,
                                :value => value)
        end
        Model::Row.new(:columns => columns)
      end
    end
  end
end
