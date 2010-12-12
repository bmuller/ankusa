require File.join File.dirname(__FILE__), 'classifier_base'

class ClassifierTest < Test::Unit::TestCase
  include ClassifierBase

  def initialize(name)
    @storage = Ankusa::CassandraStorage.new CONFIG['cassandra_host'], CONFIG['cassandra_port']
    super(name)
  end
end
