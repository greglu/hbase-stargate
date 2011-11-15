module Stargate
  module Operation
    module RowOperation

      CONVERTER = { '&' => '&amp;', '<' => '&lt;', '>' => '&gt;', "'" => '&apos;', '"' => '&quot;' }.freeze

      def set(table_name, row, columns, timestamp = nil)
        request = Request::RowRequest.new(table_name, row, timestamp)

        cells = []
        columns.each do |name, value|
          escaped_name = name.gsub(/[&<>'"]/) { |match| CONVERTER[match] }
          cell = {}
          cell["@column"] = [escaped_name].pack('m') rescue ''
          cell["$"] = [value].pack("m") rescue ''
          cell["@timestamp"] = timestamp*1000 unless timestamp.nil?
          cells << cell
        end

        json_data = Yajl::Encoder.encode({"Row" => {"@key" => [row].pack('m'), "Cell" => cells}})

        handle_exception(table_name, row) do
          response = post_response(request.create(columns.keys), json_data, {'Content-Type' => 'application/json'})
          Response::RowResponse.new(response, :create_row).parse
        end
      end

      # def get(table_name, rows, options = {})
      #   request = Request::RowRequest.new(table_name, name, options.delete(:timestamp))
      #   options[:version] ||= 1
      #
      #   results = Response::RowResponse.new(get(request.show(columns, options)), :show_row).parse
      # end

      def show_row(table_name, name, timestamp = nil, columns = nil, options = {})
        handle_exception(table_name, name) do
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
        end
      end

      def create_row(table_name, name, timestamp = nil, columns = nil)
        handle_exception(table_name, name) do
          request = Request::RowRequest.new(table_name, name, timestamp)
          data = []
          if columns
            if columns.instance_of? Array
              data = columns
            elsif columns.instance_of? Hash
              data = [columns]
            else
              raise ArgumentError, "Column data should be given as an Array or Hash"
            end
          end

          xml_data = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><CellSet>"
          xml_data << "<Row key='#{[name].pack('m') rescue ''}'>"
          data.each do |d|
            escape_name = d[:name].gsub(/[&<>'"]/) { |match| CONVERTER[match] }
            xml_data << "<Cell "
            xml_data << "timestamp='#{timestamp}' " if timestamp
            xml_data << "column='#{[escape_name].pack('m') rescue ''}'>"
            xml_data << "#{[d[:value]].pack("m") rescue ''}"
            xml_data << "</Cell>"
          end
          xml_data << "</Row></CellSet>"

          Response::RowResponse.new(post_response(request.create(data.map{|col| col[:name]}), xml_data), :create_row).parse
        end
      end

      def delete_row(table_name, name, timestamp = nil, columns = nil)
        handle_exception(table_name, name) do
          request = Request::RowRequest.new(table_name, name, timestamp)
          response = delete_response(request.delete(columns))
          Response::RowResponse.new(response, :delete_row).parse
        end
      end

      private

        def handle_exception(table_name, row = nil)
          begin
            yield
          rescue => e
            if e.to_s.include?("Table")
              raise TableNotFoundError, "Table '#{table_name}' not found"
            elsif !row.nil? && e.to_s.include?("404 Not Found")
              raise RowNotFoundError, "Row '#{row}' not found"
            else
              raise StandardError, "Following error encountered: #{e.message}"
            end
          end
        end

    end
  end
end
