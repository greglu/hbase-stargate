module Stargate
  module Operation
    module RowOperation

      CONVERTER = { '&' => '&amp;', '<' => '&lt;', '>' => '&gt;', "'" => '&apos;', '"' => '&quot;' }.freeze

      # Add a row to HBase
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  client.set("test-hbase-stargate", "row1", {"col1:cell1" => "value for column 1, cell 1", "col1:cell2" => "value 2"})
      #
      # @param [String] table_name The HBase table name
      # @param [String] row The row id
      # @param [Hash] columns hash consisting of the keys as column names and their corresponding values
      # @param [Integer] timestamp optional timestamp argument. Can be any custom value (in seconds), but HBase uses the time since epoch.
      # @return [true,false] true or false depending on whether the row was added successfully
      def set(table_name, row, columns, timestamp = nil)
        # Changing from Ruby epoch time (seconds) to Java epoch time (milliseconds)
        timestamp = timestamp*1000 unless timestamp.nil?

        cells = []
        columns.each do |name, value|
          escaped_name = name.gsub(/[&<>'"]/) { |match| CONVERTER[match] }
          cell = {}
          cell["@column"] = Base64.encode64(escaped_name) rescue ''
          cell["@timestamp"] = timestamp unless timestamp.nil?
          cell["$"] = Base64.encode64(value) rescue ''
          cells << cell
        end

        request = Request::RowRequest.new(table_name, row, timestamp)
        json_data = Yajl::Encoder.encode({"Row" => {"@key" => Base64.encode64(row), "Cell" => cells}})

        handle_exception(table_name, row) do
          response = rest_post_response(request.create(columns.keys), json_data, {'Content-Type' => 'application/json'})
          Response::RowResponse.new(response, :create_row).parse
        end
      end

      def multi_get(table_name, rows, options = {})
        if rows.is_a? String
          request = Request::RowRequest.new(table_name, rows, options.delete(:timestamp))
        elsif rows.is_a? Array

        end
        options[:version] ||= 1

        handle_exception(table_name, rows) do
          rows = {}
          Response::RowResponse.new(rest_get(request.show(options.delete(:columns), options)), :show_row).parse.each do |row|
            row.table_name = table_name
            rows[row.name] = row
          end
          return rows
        end
      end

      # Get a row from HBase
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  client.get("test-hbase-stargate", "row1", :timestamp => 1321846232, :columns => ["col1:cell1"], :version => 3)
      #
      # @param [String] table_name The HBase table name
      # @param [String] row The row id
      # @param [Hash] options the options to retrieve the row with
      # @option options [Integer] :timestamp A specific timestamp the rows should have
      # @option options [Array<String>] :columns List of columns to get
      # @option options [Integer] :versions The number of versions to get back
      # @return [Model::Row] object corresponding to the requested row, or nil if it could not be found
      def get(table_name, row, options = {})
        multi_get(table_name, row, options)[row]
      end

      # Get a row from HBase
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  row = client.show_row("test-hbase-stargate", "row1", nil, nil, :version => 2)
      #
      # @deprecated Use the {#get} method instead
      # @param [String] table_name The HBase table name
      # @param [String] name The row id
      # @param [Integer] timestamp optional timestamp
      # @param [Array<String>] columns name of the columns to retrieve. Use nil to get them all.
      # @param [Hash] options the options to retrieve the row with
      # @option options [Integer] :versions The number of versions to get back
      # @return [Model::Row] object corresponding to the requested row, or nil if it could not be found
      def show_row(table_name, name, timestamp = nil, columns = nil, options = {})
        handle_exception(table_name, name) do
          options[:version] ||= 1

          request = Request::RowRequest.new(table_name, name, timestamp)
          rows = Response::RowResponse.new(rest_get(request.show(columns, options)), :show_row).parse
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

      # Add a row to HBase
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  client.create_row("test-hbase-stargate", "row1", nil, [{ :name => "col1:cell1", :value => "row2-col1-cell1" }, { :name => "col1:cell2", :value => "row2-col1-cell2" }])
      #
      # @deprecated Use the {#set} method instead
      # @param [String] table_name The HBase table name
      # @param [String] name The row id
      # @param [Integer] timestamp optional timestamp argument. Can be any custom value (in seconds), but HBase uses the time since epoch.
      # @param [Hash, Array<Hash>] columns
      # @return [true,false] true or false depending on whether the row was added successfully
      def create_row(table_name, name, timestamp = nil, columns = nil)
        # Changing from Ruby epoch time (seconds) to Java epoch time (milliseconds)
        timestamp = timestamp*1000 unless timestamp.nil?

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
          xml_data << "<Row key='#{Base64.encode64(name) rescue ''}'>"
          data.each do |d|
            escape_name = d[:name].gsub(/[&<>'"]/) { |match| CONVERTER[match] }
            xml_data << "<Cell "
            xml_data << "timestamp='#{timestamp}' " if timestamp
            xml_data << "column='#{Base64.encode64(escape_name) rescue ''}'>"
            xml_data << "#{Base64.encode64(d[:value]) rescue ''}"
            xml_data << "</Cell>"
          end
          xml_data << "</Row></CellSet>"

          Response::RowResponse.new(rest_post_response(request.create(data.map{|col| col[:name]}), xml_data), :create_row).parse
        end
      end

      # Delete a row in HBase
      #
      # @param [String] table_name The HBase table name
      # @param [String] name The row id
      # @param [Integer] timestamp optional timestamp value (deletes all timestamp if not specified)
      # @param [Array<String>] optional list of specific columns to delete (deletes all columns if not specified)
      def delete_row(table_name, name, timestamp = nil, columns = nil)
        handle_exception(table_name, name) do
          request = Request::RowRequest.new(table_name, name, timestamp)
          response = rest_delete_response(request.delete(columns))
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
