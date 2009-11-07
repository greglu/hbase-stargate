module HBase
  module Operation
    module ScannerOperation
      # Trying to maintain some API stability for now
      def open_scanner(table_name, columns, start_row, stop_row = nil, timestamp = nil)
        warn "[DEPRECATION] This method is deprecated. Use #open_scanner(table_name, options) instead."

        open_scanner(table_name, {:columns => columns, :start_row => start_row, :stop_row => stop_row, :timestamp => timestamp})
      end

      def open_scanner(table_name, options = {})
        raise ArgumentError, "options should be given as a Hash" unless options.instance_of? Hash
        columns = options.delete(:columns)

        begin
          request = Request::ScannerRequest.new(table_name)

          xml_data = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><Scanner "
          options.each do |key,value|
            if Model::Scanner::AVAILABLE_OPTS.include? key
              xml_data << "#{Model::Scanner::AVAILABLE_OPTS[key]}='"
              xml_data << ( (key == :batch) ? value.to_s : [value.to_s].flatten.pack('m') )
              xml_data << "' "
            else
              warn "[open_scanner] Received invalid option key :#{key}"
            end
          end
          if columns
            xml_data << ">"
            [columns].flatten.each do |col|
              xml_data << "<column>#{[col].flatten.pack('m')}</column>"
            end
            xml_data << "</Scanner>"
          else
            xml_data << "/>"
          end

          scanner = Response::ScannerResponse.new(post_response(request.open, xml_data), :open_scanner).parse
          scanner.table_name = table_name
          scanner
        rescue Net::ProtocolError => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table #{table_name} Not Found!"
          else
            raise StandardError, e.to_s
          end
        end
      end

      def get_rows(scanner, limit = nil)
        warn "[DEPRECATION] Use of 'limit' here is deprecated. Instead, define the batch size when creating the scanner." if limit
        begin
          request = Request::ScannerRequest.new(scanner.table_name)
          rows = Response::ScannerResponse.new(get(request.get_rows(scanner)), :get_rows).parse
          rows.each do |row|
            row.table_name = scanner.table_name
          end
          rows
        rescue StandardError => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table #{table_name} Not Found!"
          else
            raise StandardError, e.to_s
          end
        end
      end

      def close_scanner(scanner)
        begin
          request = Request::ScannerRequest.new(scanner.table_name)
          Response::ScannerResponse.new(delete_response(request.close(scanner)), :close_scanner).parse
        rescue StandardError => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table #{table_name} Not Found!"
          else
            raise StandardError, e.to_s
          end
        end
      end
    end
  end
end
