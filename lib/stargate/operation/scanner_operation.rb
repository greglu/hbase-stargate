module Stargate
  module Operation
    module ScannerOperation
      # Trying to maintain some API stability for now
      def open_scanner(table_name, columns, start_row, stop_row = nil, timestamp = nil)
        warn "[DEPRECATION] This method is deprecated. Use #open_scanner(table_name, options = {}) instead."

        open_scanner(table_name, {:columns => columns, :start_row => start_row, :stop_row => stop_row, :timestamp => timestamp})
      end

      def open_scanner(table_name, options = {})
        raise ArgumentError, "options should be given as a Hash" unless options.instance_of? Hash
        columns = options.delete(:columns)
        batch = options.delete(:batch) || "10"

        begin
          request = Request::ScannerRequest.new(table_name)

          xml_data = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><Scanner batch='#{batch}' "
          options.each do |key,value|
            if Model::Scanner::AVAILABLE_OPTS.include? key
              xml_data << "#{Model::Scanner::AVAILABLE_OPTS[key]}='#{[value.to_s].flatten.pack('m')}' "
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
          scanner.batch_size = batch
          scanner
        rescue Net::ProtocolError => e
          raise StandardError, e.to_s
        end
      end

      def get_rows(scanner, limit = nil)
        begin
          request = Request::ScannerRequest.new(scanner.table_name)
          request_url = request.get_rows(scanner) # The url to the scanner is the same for each batch

          rows = []
          begin
            # Loop until we've reached the limit, or the scanner was exhausted (HTTP 204 returned)
            until (limit && rows.size >= limit) || (response = get_response(request_url)).code == "204"
              rows.concat Response::ScannerResponse.new(response.body, :get_rows).parse

              rows.each do |row|
                row.table_name = scanner.table_name
              end
            end
          rescue Exception => e
            raise Stargate::ScannerError, "Scanner failed while getting rows. #{e.message}"
          end

          # Prune the last few rows if the limit was passed.
          (limit) ? rows.slice(0, limit) : rows
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
