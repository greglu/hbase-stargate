module Stargate
  module Response
    class ScannerResponse < BasicResponse
      attr_reader :method

      def initialize(raw_data, method)
        @method = method
        super(raw_data)
      end

      def parse_content(raw_data)
        case @method
        when :open_scanner
          case raw_data.status
          when 201
            Stargate::Model::Scanner.new(:scanner_url => raw_data.headers["Location"])
          when 404
            raise TableNotFoundError, "Table #{table_name} Not Found!"
          else
            raise StandardError, "Unable to open scanner. Received the following message: #{raw_data.status_line}"
          end
        when :get_rows
          # Dispatch it to RowResponse, since that method is made
          # to deal with rows already.
          RowResponse.new(raw_data, :show_row).parse
        when :close_scanner
          case raw_data.status
          when 200
            return true
          else
            raise StandardError, "Unable to close scanner. Received the following message: #{raw_data.status_line}"
          end
        else
          puts "method '#{@method}' not supported yet"
        end
      end
    end
  end
end
