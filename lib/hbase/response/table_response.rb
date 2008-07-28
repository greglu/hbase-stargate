module HBase
  module Response
    class TableResponse < BasicResponse
      def parse_content(raw_data)
        doc = REXML::Document.new(raw_data)
        table = doc.elements["table"]

        name = table.elements["name"].text.strip
        column_families = []
        table.elements["columnfamilies"].elements.each("columnfamily") do |columnfamily|
          colname = columnfamily.elements["name"].text.strip
          compression = columnfamily.elements["compression"].text.strip
          bloomfilter = columnfamily.elements["bloomfilter"].text.strip.to_b
          max_versions = columnfamily.elements["max-versions"].text.strip.to_i
          maximum_cell_size = columnfamily.elements["maximum-cell-size"].text.strip.to_i

          column_descriptor = Model::ColumnDescriptor.new(:name => colname,
                                                          :compression => Model::CompressionType.to_compression_type(compression),
                                                          :bloomfilter => bloomfilter,
                                                          :max_versions => max_versions,
                                                          :maximum_cell_size => maximum_cell_size)
          column_families << column_descriptor
        end
        Model::TableDescriptor.new(:name => name, :column_families => column_families)
      end
    end
  end
end
