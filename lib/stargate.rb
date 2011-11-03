module Stargate end

$:.unshift File.dirname(__FILE__)

require 'stargate/client'
require 'stargate/exception'
require 'stargate/model'
require 'stargate/request'
require 'stargate/response'
