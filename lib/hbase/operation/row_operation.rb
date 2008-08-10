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

      def create_row(table_name, name, timestamp = nil, *args)
        request = Request::RowRequest.new(table_name, name, timestamp)
        data = []
        if args.instance_of? Array
          data = args
        elsif args.instance_of? Hash
          data = [args]
        else
          raise StandardError, "Only Array or Hash data accepted"
        end
        xml_data ="<?xml version='1.0' encoding='UTF-8'?><columns>"
        data.each do |d|
          xml_data << "<column><name>#{d[:name]}</name>"
          xml_data << "<value>#{[d[:value]].pack("m") rescue ''}</value></column>"
        end
        xml_data << "</columns>"

        Response::RowResponse.new(post(request.create, xml_data))
      end

      def delete_row(table_name, name, timestamp = nil, columns = nil)
        request = Request::RowRequest.new(table_name, name, timestamp)
        Response::RowResponse.new(delete(request.delete(columns)))
      end
    end
  end
end
