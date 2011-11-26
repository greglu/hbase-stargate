module Stargate
  module Operation
    module ScannerOperation

      # Create a scanner for the given table along with options defined in the {Model::Scanner::AVAILABLE_OPTS} hash.
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  scanner = client.open_scanner("test-hbase-stargate", :batch_size => 1000, :start_row => "row1", :end_row => "row2")
      #
      # @see Model::Scanner::AVAILABLE_OPTS
      # @param [String] table_name the table name
      # @param [Hash] options options for the scanner
      # @return [Model::Scanner] object representing the scanner
      def open_scanner(table_name, options = {})
        raise ArgumentError, "options should be given as a Hash" unless options.instance_of? Hash
        columns = options.delete(:columns)
        batch = options.delete(:batch) || "100"
        start_time = options.delete(:start_time)
        end_time = options.delete(:end_time)

        begin
          request = Request::ScannerRequest.new(table_name)

          xml_data = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><Scanner batch='#{batch}' "
          xml_data += "startTime='#{start_time}' " if start_time
          xml_data += "endTime='#{end_time}' " if end_time

          options.each do |key,value|
            if Model::Scanner::AVAILABLE_OPTS.include? key
              xml_data << "#{Model::Scanner::AVAILABLE_OPTS[key]}='#{Base64.encode64(value.to_s)}' "
            else
              warn "[open_scanner] Received invalid option key :#{key}"
            end
          end
          if columns
            xml_data << ">"
            [columns].flatten.each do |col|
              xml_data << "<column>#{Base64.encode64(col)}</column>"
            end
            xml_data << "</Scanner>"
          else
            xml_data << "/>"
          end

          scanner = Response::ScannerResponse.new(rest_post_response(request.open, xml_data), :open_scanner).parse
          scanner.table_name = table_name
          scanner.batch_size = batch
          scanner
        rescue => e
          raise StandardError, e.to_s
        end
      end

      # Execute a given block on each row returned by the {Model::Scanner}. This will only store
      # a batch size (defined during scanner creation) number of records and keep requesting more
      # until a break or limit is reached. This means that it's safe to run this method against
      # the whole dataset (assuming that each row encountered isn't being stored elsewhere).
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  scanner = client.open_scanner("test-hbase-stargate")
      #  client.each_row(scanner) do |row|
      #    puts row.name
      #  end
      #
      # @see #open_scanner
      # @see Model::Scanner
      # @param [Model::Scanner] scanner Scanner object that was previously open
      # @yield [Model::Row] code to run against each row
      def each_row(scanner, &block)
        begin
          request = Request::ScannerRequest.new(scanner.table_name)
          request_url = request.get_rows(scanner) # The url to the scanner is the same for each batch

          begin
            # Loop until we've reached the limit, or the scanner was exhausted (HTTP 204 returned)
            until (response = rest_get_response(request_url)).status == 204
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

      # Get a list of rows from a given {Model::Scanner} that was previously created by the {#open_scanner} method.
      # If a limit is given, then this method will only retrieve that amount, otherwise it will keep getting
      # rows until the scanner is exhausted (i.e. there no more records).
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  scanner = client.open_scanner("test-hbase-stargate")
      #  rows = client.get_rows(scanner, 10)
      #
      # @see #open_scanner
      # @see Model::Scanner
      # @param [Model::Scanner] scanner Scanner object that was previously open
      # @param [Integer] limit return this maximum number of records, or return all if nil
      # @return [Array<Model::Row>] list of row records
      def get_rows(scanner, limit = nil)
        rows = []
        each_row(scanner) do |row|
          break if !limit.nil? && rows.size >= limit
          rows << row
        end
        return rows
      end

      # Close a {Model::Scanner} object
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  scanner = client.open_scanner("test-hbase-stargate")
      #  client.each_row(scanner) do |row|
      #    puts row.name
      #  end
      #  client.close_scanner(scanner)
      #
      # @see #open_scanner
      # @see Model::Scanner
      # @param [Model::Scanner] scanner Scanner object that was previously open
      def close_scanner(scanner)
        begin
          request = Request::ScannerRequest.new(scanner.table_name)
          Response::ScannerResponse.new(rest_delete_response(request.close(scanner)), :close_scanner).parse
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
