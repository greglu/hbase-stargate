module HBase
  module Operation
    module MetaOperation
      def list_tables
        request = Request::MetaRequest.new
        Response::MetaResponse.new(get(request.list_tables), :list_tables).parse
      end

      def version
        request = Request::MetaRequest.new
        get(request.version, {"Accept" => "text/plain"}).strip
      end

      def cluster_version
        request = Request::MetaRequest.new
        get(request.cluster_version, {"Accept" => "text/plain"}).strip
      end
    end
  end
end
