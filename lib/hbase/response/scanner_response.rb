module HBase
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
          case raw_data
          when Net::HTTPCreated
            HBase::Model::Scanner.new(:scanner_url => raw_data["Location"])
          else
            if raw_data.message.include?("TableNotFoundException")
              raise TableNotFoundError, "Table #{table_name} Not Found!"
            else
              raise StandardError, "Unable to open scanner. Received the following message: #{raw_data.message}"
            end
          end
        when :get_rows
          # Dispatch it to RowResponse, since that method is made
          # to deal with rows already.
          RowResponse.new(raw_data).parse
        when :close_scanner
          case raw_data
          when Net::HTTPOK
            return true
          else
            raise StandardError, "Unable to close scanner. Received the following message: #{raw_data.message}"
          end
        else
          puts "method '#{@method}' not supported yet"
        end
      end
    end
  end
end
