module Stargate
  module Response
    class TableResponse < BasicResponse
      def parse_content(raw_data)
        table = Yajl::Parser.parse(raw_data)
        name = table["name"].strip

        column_families = []
        table["ColumnSchema"].each do |columnfamily|
          colname = columnfamily["name"].strip
          compression = columnfamily["COMPRESSION"].strip
          bloomfilter = columnfamily["BLOOMFILTER"].strip
          max_versions = columnfamily["VERSIONS"].strip.to_i

          column_descriptor = Model::ColumnDescriptor.new(:name => colname,
                                                          :compression => Model::CompressionType.to_compression_type(compression),
                                                          :bloomfilter => Model::BloomType.to_bloom_type(bloomfilter),
                                                          :max_versions => max_versions)
          column_families << column_descriptor
        end

        Model::TableDescriptor.new(:name => name, :column_families => column_families)
      end
    end
  end
end
