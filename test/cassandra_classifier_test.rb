require File.join File.dirname(__FILE__), 'classifier_base'
require 'ankusa/cassandra_storage'

module CassandraClassifierBase
  def initialize(name)
    @storage = Ankusa::CassandraStorage.new CONFIG['cassandra_host'], CONFIG['cassandra_port'], "ankusa_test"
    super(name)
  end
end

class NBClassifierTest < Test::Unit::TestCase
  include CassandraClassifierBase
  include NBClassifierBase
end

class KLClassifierTest < Test::Unit::TestCase
  include CassandraClassifierBase
  include KLClassifierBase
end
