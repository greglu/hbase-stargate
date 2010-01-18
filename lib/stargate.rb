module Stargate
  VERSION = File.read(File.join(File.dirname(__FILE__), "..", "VERSION")).chomp.freeze
end

require File.join(File.dirname(__FILE__), "stargate", "client")
require File.join(File.dirname(__FILE__), "stargate", "exception")
require File.join(File.dirname(__FILE__), "stargate", "model")
require File.join(File.dirname(__FILE__), "stargate", "request")
require File.join(File.dirname(__FILE__), "stargate", "response")
