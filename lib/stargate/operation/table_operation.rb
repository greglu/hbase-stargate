module Stargate
  module Operation
    module TableOperation

      def table_exists?(name)
        begin
          request = Request::TableRequest.new(name)
          table_response(name, get_response(request.show))
          true
        rescue Stargate::Exception
          false
        end
      end

      def show_table(name)
        request = Request::TableRequest.new(name)
        response = table_response(name, get_response(request.show))
        Response::TableResponse.new(response.body, :show).parse
      end

      ##
      #
      #
      def create_table(name, *args)
        raise ArgumentError, "Table name must be of type String" unless name.is_a? String

        # Creating the table's structure as a Hash then turning it into JSON
        table_structure = {"name" => name, "IS_META" => false, "IS_ROOT" => false}
        table_structure["ColumnSchema"] = []

        # The arguments for defining the column families
        # can be presented as a collection of Strings and Hashes
        for column in args
          case column

          # If the column is defined by a String, then treat it as a name
          when String
            table_structure["ColumnSchema"] << {"name" => column}

          # If the column is defined by a Hash, then resolve it into the
          # proper collection of attributes
          when Hash
            resolved_column = {}
            column.each do |k,v|
              if Model::ColumnDescriptor::AVAILABLE_OPTS.include? k
                resolved_column[Model::ColumnDescriptor::AVAILABLE_OPTS[k]] = v
              else
                raise ArgumentError, "Argument '#{k}' is not valid"
              end
            end
            table_structure["ColumnSchema"] << resolved_column

          else
            raise ArgumentError, "Columns can only be defined by a String or Hash"
          end
        end

        # JSON, activate!
        json_structure = table_structure.to_json

        request = Request::TableRequest.new(name)
        response = post_response(request.create, json_structure)

        case response
        when Net::HTTPCreated
          Response::TableResponse.new(json_structure, :show).parse
        else
          raise TableCreationError, "Error while creating table #{name}:\n" + response.body
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
        request = Request::TableRequest.new(name)
        response = delete_response(request.delete)
        Response::TableResponse.new(response, :delete).parse
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

      def table_regions(name)
        request = Request::TableRequest.new(name)
        response = table_response(name, get_response(request.regions))
        Response::TableResponse.new(response.body, :regions).parse
      end

    private

      def table_response(name, response)
        case response
        when Net::HTTPOK
          response
        when Net::HTTPNotFound
          raise TableNotFoundError, "Table '#{name}' does not exist"
        else
          if response.body.include?("org.apache.hadoop.hbase.TableNotFoundException")
            raise TableNotFoundError, "Table '#{name}' does not exist"
          else
            raise TableError, "Unknown error occurred while accessing table '#{name}'"
          end
        end
      end

    end
  end
end
