module Stargate
  module Operation
    module MetaOperation

      # Get a list of tables
      #
      # @return [Array<Model::TableDescriptor>] array of TableDescriptor
      def list_tables
        request = Request::MetaRequest.new
        Response::MetaResponse.new(rest_get(request.list_tables), :list_tables).parse
      end

      # Get the version string of the REST server
      #
      # @return [String] version number
      def version
        request = Request::MetaRequest.new
        rest_get(request.version, {"Accept" => "text/plain"}).strip
      end

      # Get the version of the HBase cluster
      #
      # @return [String] cluster version number
      def cluster_version
        request = Request::MetaRequest.new
        rest_get(request.cluster_version, {"Accept" => "text/plain"}).strip
      end

    end
  end
end
