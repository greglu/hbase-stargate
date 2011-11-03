module Stargate
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
        raise NotImplementedError, "Currently not supported in Stargate client"
      end

      def show_row(table_name, name, timestamp = nil, columns = nil, options = { })
        begin
          options[:version] ||= 1

          request = Request::RowRequest.new(table_name, name, timestamp)
          rows = Response::RowResponse.new(get(request.show(columns, options)), :show_row).parse
          if rows.size == 1
            row = rows.first
            row.table_name = table_name
            row
          else
            rows.each do |row|
              row.table_name = table_name
            end
            rows
          end
        rescue => e
          # TODO: Use better handling instead of this.
          if e.to_s.include?("Table")
            raise TableNotFoundError, "Table '#{table_name}' Not Found"
          elsif e.to_s.include?("404")
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

          xml_data = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><CellSet>"
          xml_data << "<Row key='#{[name].pack('m') rescue ''}'>"
          data.each do |d|
            escape_name = d[:name].gsub(/[&<>'"]/) { |match| Converter[match] }
            xml_data << "<Cell "
            xml_data << "timestamp='#{timestamp}' " if timestamp
            xml_data << "column='#{[escape_name].pack('m') rescue ''}'>"
            xml_data << "#{[d[:value]].pack("m") rescue ''}"
            xml_data << "</Cell>"
          end
          xml_data << "</Row></CellSet>"

          Response::RowResponse.new(post_response(request.create(data.map{|col| col[:name]}), xml_data), :create_row).parse
        rescue => e
          if e.to_s.include?("Table")
            raise TableNotFoundError, "Table '#{table_name}' Not Found"
          elsif e.to_s.include?("Row")
            raise RowNotFoundError, "Row '#{name}' Not Found"
          else
            raise StandardError, "Error encountered while trying to create row: #{e.message}"
          end
        end
      end

      def delete_row(table_name, name, timestamp = nil, columns = nil)
        begin
          request = Request::RowRequest.new(table_name, name, timestamp)
          Response::RowResponse.new(delete_response(request.delete(columns)), :delete_row).parse
        rescue => e
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
