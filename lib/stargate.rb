module Stargate end

require 'pathname'
pwd = Pathname(__FILE__).dirname
$:.unshift(pwd.to_s) unless $:.include?(pwd.to_s) || $:.include?(pwd.expand_path.to_s)

require 'stargate/client'
require 'stargate/exception'
require 'stargate/model'
require 'stargate/request'
require 'stargate/response'
