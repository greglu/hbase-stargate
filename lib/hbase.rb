module HBase
  VERSION = File.read(File.join(File.dirname(__FILE__), "..", "VERSION")).chomp.freeze
end

require File.join(File.dirname(__FILE__), "hbase", "client")
require File.join(File.dirname(__FILE__), "hbase", "exception")
require File.join(File.dirname(__FILE__), "hbase", "model")
require File.join(File.dirname(__FILE__), "hbase", "request")
require File.join(File.dirname(__FILE__), "hbase", "response")
