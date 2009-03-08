module HBase
  module Operation
    module ScannerOperation
      def open_scanner(table_name, columns, start_row = nil, stop_row = nil, timestamp = nil)
        begin
          request = Request::ScannerRequest.new(table_name)
          scanner = Response::ScannerResponse.new(post(request.open(columns, start_row, stop_row, timestamp))).parse
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

      def get_rows(scanner, limit = 1)
        begin
          request = Request::ScannerRequest.new(scanner.table_name)
          rows = Response::ScannerResponse.new(post(request.get_rows(scanner.scanner_id, limit))).parse
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
          Response::ScannerResponse.new(delete(request.close(scanner.scanner_id)))
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
