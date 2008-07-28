$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'hbase/client'
require 'hbase/exception'
require 'hbase/model'
require 'hbase/request'
require 'hbase/response'

module HBase; end

class Object
  def to_proc
    proc { |obj, *args| obj.send(self, *args) }
  end

  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class NilClass #:nodoc:
  def blank?
    true
  end
end

class Array #:nodoc:
  alias_method :blank?, :empty?
end

class Hash #:nodoc:
  alias_method :blank?, :empty?
end

class String #:nodoc:
  def blank?
    self !~ /\S/
  end

  def to_b
    self == "true" ? true : false
  end
end
