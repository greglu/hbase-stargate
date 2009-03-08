module HBase
  module Response
    class ScannerResponse < BasicResponse
      def parse_content(raw_data)
        puts raw_data

        doc = REXML::Document.new(raw_data)

        if doc.elements["/scanner"] && doc.elements["/scanner"].has_elements?
          scanner = doc.elements["scanner"]
          id = scanner.elements["id"].text.strip.to_i
          Model::Scanner.new(:scanner_id => id)

        elsif doc.elements["rows"] && doc.elements["rows"].has_elements?
          doc = doc.elements["rows"]
          rows = []
          doc.elements.each("row") do |row|
            row_name = row.elements["name"].text.strip.unpack("m").first
            columns = []
            row.elements.each("column") do |col|
              name = col.elements["name"].text.strip.unpack("m").first
              value = col.elements["value"].text.strip.unpack("m").first rescue nil
              timestamp = col.elements["timestamp"].text.strip.to_i
              columns << Model::Column.new(:name => name,
                                           :value => value,
                                           :timestamp => timestamp)
            end
            rows << Model::Row.new(:name => row_name, :columns => columns)
          end
          rows
        end
      end
    end
  end
end
