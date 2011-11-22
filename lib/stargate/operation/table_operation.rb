module Stargate
  module Operation
    module TableOperation

      # Get the TableDescriptor object for the table of the given name
      #
      # @param [String] name the table name
      # @return [Model::TableDescriptor] TableDescriptor object corresponding to the table
      def show_table(name)
        begin
          request = Request::TableRequest.new(name)
          Response::TableResponse.new(rest_get(request.show)).parse
        rescue => e
          raise TableNotFoundError, "Table '#{name}' Not found"
        end
      end

      # Create a table in HBase. Pass in one or more arguments after the table name to configure the column families
      # that should be created. The arguments can be a mix of String (no options) or a Hash with options specified
      # from the key names of the {Model::ColumnDescriptor::AVAILABLE_OPTS} hash.
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  table_options = { :name => 'columnfamily1', \
      #          :max_versions => 3, \
      #          :compression => Stargate::Model::CompressionType::NONE, \
      #          :in_memory => false, \
      #          :block_cache => false, \
      #          :ttl => -1, \
      #          :max_cell_size => 2147483647, \
      #          :bloomfilter => Stargate::Model::BloomType::NONE \
      #        }
      #  client.create_table('test-hbase-stargate', table_options)
      #
      # @see Model::ColumnDescriptor::AVAILABLE_OPTS
      # @param [String] name the table name
      # @param [Array<String, Hash>] args column family definitions. When it's a String, it will create
      #     a column family with default options. Otherwise you can pass a hash with the options
      #     defined in {Model::ColumnDescriptor::AVAILABLE_OPTS}
      # @return [true,false] true if the table was created successfully, false otherwise
      def create_table(name, *args)
        raise ArgumentError, "Table name must be of type String" unless name.instance_of? String
        raise ArgumentError, "#alter_table requires column family arguments" if args.empty?

        request = Request::TableRequest.new(name)
        begin
          rest_put_response(request.create, generate_table_xml(name, args)).status == 201
        rescue => e
          raise TableFailCreateError, e.message
        end
      end

      # Will alter the table of the given name. Can be used to add new column families to a table
      # or modify existing ones. The column family configurations don't have to define a complete
      # set, and can be given partial changes.
      #
      # Example:
      #  client = Stargate::Client.new("http://localhost:8080")
      #  table_options = { :name => 'columnfamily1', \
      #          :max_versions => 3, \
      #          :compression => Stargate::Model::CompressionType::NONE, \
      #          :in_memory => false, \
      #          :block_cache => false, \
      #          :ttl => -1, \
      #          :max_cell_size => 2147483647, \
      #          :bloomfilter => Stargate::Model::BloomType::NONE \
      #        }
      #  client.create_table('test-hbase-stargate', table_options)
      #
      #  # this will alter the existing column family 'columnfamily1' to store 1 version only, and create
      #  # a new column family named 'columnfamily2'
      #  client.alter_table('test-hbase-stargate', {:name => 'columnfamily1', :max_versions => 1}, 'columnfamily2')
      #
      # @param [String] name the table name
      # @param [Array<String, Hash>] args column family definitions. When it's a String, it will create
      #     a column family with default options. Otherwise you can pass a hash with the options
      #     defined in {Model::ColumnDescriptor::AVAILABLE_OPTS}
      # @return [true,false] true if the altering was successful, false otherwise
      def alter_table(name, *args)
        raise ArgumentError, "Table name must be of type String" unless name.instance_of? String
        raise ArgumentError, "#alter_table requires column family arguments" if args.empty?

        request = Request::TableRequest.new(name)

        begin
          response = rest_post_response(request.create, generate_table_xml(name, args))
          response.status == 200
        rescue => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table '#{name}' not exists"
          else
            raise TableFailCreateError, e.message
          end
        end
      end

      # Delete the table with the given name and optionally choose certain columns to delete
      #
      # @param [String] name the table name
      # @param [Array<String>] [Deprecated] list of column names
      def delete_table(name, columns = nil)
        begin
          request = Request::TableRequest.new(name)
          Response::TableResponse.new(rest_delete(request.delete(columns)))
        rescue => e
          if e.to_s.include?("TableNotFoundException")
            raise TableNotFoundError, "Table '#{name}' not exists"
          elsif e.to_s.include?("TableNotDisabledException")
            raise TableNotDisabledError, "Table '#{name}' not disabled"
          end
        end
      end

      # (see #delete_table)
      def destroy_table(name, columns = nil)
        delete_table(name, columns)
      end

      # List of table regions
      #
      def table_regions(name, start_row = nil, end_row = nil)
        raise NotImplementedError, "Getting the table regions is not supported yet"
      end

      private

      def generate_table_xml(table_name, args)
        xml_data = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><TableSchema name='#{table_name}' IS_META='false' IS_ROOT='false'>"
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
            raise ArgumentError, "#{arg.class.to_s} of #{arg.to_s} is not of Hash Type"
          end
        end
        xml_data << "</TableSchema>"
        return xml_data
      end

    end
  end
end
