module HBase
  module Operation
    module TableOperation
      def show_table(name)
        begin
          request = Request::TableRequest.new(name)
          table_descriptor = Response::TableResponse.new(get(request.show)).parse
        rescue Net::ProtocolError => e
          raise TableNotFoundError, "Table '#{name}' Not found"
        end
      end

      def create_table(name, *args)
        request = Request::TableRequest.new(nil)

        raise StandardError, "Table name must be of type String" unless name.instance_of? String

        begin
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
        rescue Net::ProtocolError => e
          if e.to_s.include?("TableExistsException")
            raise TableExistsError, "Table '#{name}' already exists"
          else
            raise TableFailCreateError, e.message
          end
        end
      end

      def alter_table(name, *args)
        raise StandardError, "Table name must be of type String" unless name.instance_of? String

        request = Request::TableRequest.new(name)

        begin
          xml_data = construct_xml_stream(name, *args)
          Response::TableResponse.new(put(request.update, xml_data))
        rescue Net::ProtocolError => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table '#{name}' not exists"
          else
            raise TableFailCreateError, e.message
          end
        end
      end

      def delete_table(name, columns = nil)
        begin
          request = Request::TableRequest.new(name)
          Response::TableResponse.new(delete(request.delete(columns)))
        rescue Net::ProtocolError => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table '#{name}' not exists"
          elsif e.to_s.include?("TableNotDisabledException")
            raise TableNotDisabledError, "Table '#{name}' not disabled"
          end
        end
      end

      def destroy_table(name, columns = nil)
        delete_table(name, columns)
      end

      def enable_table(name)
        begin
          request = Request::TableRequest.new(name)
          Response::TableResponse.new(post(request.enable))
        rescue Net::ProtocolError => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table '#{name}' not exists"
          else
            raise TableFailEnableError, "Table '#{name}' can not be enabled"
          end
        end
      end

      def disable_table(name)
        begin
          request = Request::TableRequest.new(name)
          Response::TableResponse.new(post(request.disable))
        rescue Net::ProtocolError => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table '#{name}' not exists"
          else
            raise TableFailDisableError, "Table '#{name}' can not be disabled"
          end
        end
      end

      def table_regions(name, start_row = nil, end_row = nil)
      end

      private
      def construct_xml_stream(name, *args)
        xml_data = "<?xml version='1.0' encoding='UTF-8'?><table><name>#{name}</name><columnfamilies>"
        for arg in args
          if arg.instance_of? String
            xml_data << "<columnfamily><name>#{arg}</name></columnfamily>"
          elsif arg.instance_of? Hash
            xml_data << "<columnfamily>"
            arg.each do |k,v|
              if Model::ColumnDescriptor::AVAILABLE_OPTS.include? k
                xml_data << "<#{Model::ColumnDescriptor::AVAILABLE_OPTS[k]}>#{v}</#{Model::ColumnDescriptor::AVAILABLE_OPTS[k]}>"
              else
                xml_data << "<metadata><name>#{k}</name><value>#{v}</value></metadata>"
              end
            end
            xml_data << "</columnfamily>"
          else
            raise StandardError, "#{arg.class.to_s} of #{arg.to_s} is not of Hash Type"
          end
        end
        xml_data << "</columnfamilies></table>"

        xml_data
      end
    end
  end
end
