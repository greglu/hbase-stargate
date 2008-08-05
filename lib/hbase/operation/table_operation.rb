module HBase
  module Operation
    module TableOperation
      def show_table(name)
        request = Request::TableRequest.new(name)
        table_descriptor = Response::TableResponse.new(get(request.show)).parse
      end

      def create_table(name, *args)
        request = Request::TableRequest.new(nil)

        raise StandardError, "Table name must be of type String" unless name.instance_of? String

        xml_data = "<?xml version='1.0' encoding='UTF-8'?><table><name>#{name}</name><columnfamilies>"
        for arg in args
          if arg.instance_of? String
            xml_data << "<columnfamily><name>#{arg}</name></columnfamily>"
          elsif arg.instance_of? Hash
            xml_data << "<columnfamily>"
            arg.each do |k,v|
              if Model::ColumnDescriptor::AVAILABLE_OPTS.include? k
                xml_data << "<#{Model::ColumnDescriptor::AVAILABLE_OPTS[k]}>#{v}</#{Model::ColumnDescriptor::AVAILABLE_OPTS[k]}>"
              end
            end
            xml_data << "</columnfamily>"
          else
            raise StandardError, "#{arg.class.to_s} of #{arg.to_s} is not of Hash Type"
          end
        end
        xml_data << "</columnfamilies></table>"
        Response::TableResponse.new(post(request.create, xml_data))
      end

      def delete_table(name)
        request = Request::TableRequest.new(name)
        Response::TableResponse.new(delete(request.delete))
      end

      def enalbe_table(name)
        request = Request::TableRequest.new(name)
        Response::TableResponse.new(post(request.enable))
      end

      def disable_table(name)
        request = Request::TableRequest.new(name)
        Response::TableResponse.new(post(request.disable))
      end

      def table_regions(name, start_row = nil, end_row = nil)
      end
    end
  end
end
