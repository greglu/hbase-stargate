module HBase
  module Operation
    module RowOperation
      Converter = {
        '&' => '&amp;',
        '<' => '&lt;',
        '>' => '&gt;',
        "'" => '&apos;',
        '"' => '&quot;'
      }

      def row_timestamps(table_name, name)
        raise NotImplementedError, "Currently not supported in native hbase client"
      end

      def show_row(table_name, name, timestamp = nil, columns = nil, options = { })
        begin
          request = Request::RowRequest.new(table_name, name, timestamp)
          row = Response::RowResponse.new(get(request.show(columns, options))).parse
          row.table_name = table_name
          row.timestamp = timestamp
          row
        rescue Net::ProtocolError => e
          if e.to_s.include?("Table")
            raise TableNotFoundError, "Table '#{table_name}' Not Found"
          elsif e.to_s.include?("Row")
            raise RowNotFoundError, "Row '#{name}' Not Found"
          end
        end
      end

      def create_row(table_name, name, timestamp = nil, columns = nil)
        begin
          request = Request::RowRequest.new(table_name, name, timestamp)
          data = []
          if columns
            if columns.instance_of? Array
              data = columns
            elsif columns.instance_of? Hash
              data = [columns]
            else
              raise StandardError, "Only Array or Hash data accepted"
            end
          end
          xml_data ="<?xml version='1.0' encoding='UTF-8'?><columns>"
          data.each do |d|
            escape_name = d[:name].gsub(/[&<>'"]/) { |match| Converter[match] }
            xml_data << "<column><name>#{escape_name}</name>"
            xml_data << "<value>#{[d[:value]].pack("m") rescue ''}</value></column>"
          end
          xml_data << "</columns>"

          post(request.create, xml_data)
        rescue Net::ProtocolError => e
          if e.to_s.include?("Table")
            raise TableNotFoundError, "Table '#{table_name}' Not Found"
          elsif e.to_s.include?("Row")
            raise RowNotFoundError, "Row '#{name}' Not Found"
          end
        end
      end

      def delete_row(table_name, name, timestamp = nil, columns = nil)
        begin
          request = Request::RowRequest.new(table_name, name, timestamp)
          Response::RowResponse.new(delete(request.delete(columns)))
        rescue Net::ProtocolError => e
          if e.to_s.include?("Table")
            raise TableNotFoundError, "Table '#{table_name}' Not Found"
          elsif e.to_s.include?("Row")
            raise RowNotFoundError, "Row '#{name}' Not Found"
          end
        end
      end
    end
  end
end
