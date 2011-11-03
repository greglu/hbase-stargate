module Stargate
  module Operation
    module TableOperation
      def show_table(name)
        begin
          request = Request::TableRequest.new(name)
          Response::TableResponse.new(get(request.show)).parse
        rescue Net::ProtocolError
          raise TableNotFoundError, "Table '#{name}' Not found"
        end
      end

      def create_table(name, *args)
        request = Request::TableRequest.new(name)

        raise StandardError, "Table name must be of type String" unless name.instance_of? String

        begin
          xml_data = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><TableSchema name='#{name}' IS_META='false' IS_ROOT='false'>"
          for arg in args
            if arg.instance_of? String
              xml_data << "<ColumnSchema name='#{arg}' />"
            elsif arg.instance_of? Hash
              xml_data << "<ColumnSchema "

              arg.each do |k,v|
                if Model::ColumnDescriptor::AVAILABLE_OPTS.include? k
                  xml_data << "#{Model::ColumnDescriptor::AVAILABLE_OPTS[k]}='#{v}' "
                end
              end

              xml_data << "/>"
            else
              raise StandardError, "#{arg.class.to_s} of #{arg.to_s} is not of Hash Type"
            end
          end
          xml_data << "</TableSchema>"
          put_response(request.create, xml_data).is_a?(Net::HTTPSuccess)
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
        warn "[DEPRECATION] Explicitly enabling tables isn't required anymore. HBase Stargate will enable/disable as needed."
      end

      def disable_table(name)
        warn "[DEPRECATION] Explicitly disabling tables isn't required anymore. HBase Stargate will enable/disable as needed."
      end

      def table_regions(name, start_row = nil, end_row = nil)
      end

    end
  end
end
