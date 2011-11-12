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
        batch = options.delete(:batch) || "1000"
        start_time = options.delete(:start_time)
        end_time = options.delete(:end_time)

        begin
          request = Request::ScannerRequest.new(table_name)

          xml_data = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><Scanner batch='#{batch}' "
          xml_data += "startTime='#{start_time}' " if start_time
          xml_data += "endTime='#{end_time}' " if end_time

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
        rescue => e
          raise StandardError, e.to_s
        end
      end

      def each_row(scanner, &block)
        begin
          request = Request::ScannerRequest.new(scanner.table_name)
          request_url = request.get_rows(scanner) # The url to the scanner is the same for each batch

          begin
            # Loop until we've reached the limit, or the scanner was exhausted (HTTP 204 returned)
            until (response = get_response(request_url)).status == 204
              rows = Response::ScannerResponse.new(response.body, :get_rows).parse

              rows.each do |row|
                row.table_name = scanner.table_name
                block.call(row)
              end
            end
          rescue => e
            raise Stargate::ScannerError, "Scanner iteration failed with the following error:\n#{e.message}"
          end
        rescue => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table #{table_name} Not Found!"
          else
            raise StandardError, e.to_s
          end
        end
      end

      def get_rows(scanner, limit = nil)
        rows = []
        each_row(scanner) do |row|
          break if !limit.nil? && rows.size >= limit
          rows << row
        end
        return rows
      end

      def close_scanner(scanner)
        begin
          request = Request::ScannerRequest.new(scanner.table_name)
          Response::ScannerResponse.new(delete_response(request.close(scanner)), :close_scanner).parse
        rescue => e
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
