module HBase
  module Operation
    module RowOperation
      def row_timestamps(table_name, name)
        raise NotImplementedError, "Currently not supported in native hbase client"
      end

      def show_row(table_name, name, timestamp = nil, columns = nil)
        request = Request::RowRequest.new(table_name, name, timestamp)
        row = Response::RowResponse.new(get(request.show(columns))).parse
        row.table_name = table_name
        row.name = name
        row.timestamp = timestamp
        row
      end

      def create_row(table_name, name, timestamp = nil, data = { })
        request = Request::RowRequest.new(table_name, name, timestamp)
        xml_data =<<EOF
<?xml version='1.0' encoding='UTF-8'?>
<column>
  <name>#{data[:name]}</name>
  <value>#{[data[:value]].pack("m")}</value>
</column>
EOF
        Response::RowResponse.new(post(request.create, xml_data))
      end

      def delete_row(table_name, name, timestamp = nil, columns = nil)
        request = Request::RowRequest.new(table_name, name, timestamp)
        Response::RowResponse.new(delete(request.delete(columns)))
      end
    end
  end
end
