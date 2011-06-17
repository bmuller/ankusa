require File.join File.dirname(__FILE__), 'classifier_base'
require 'ankusa/mongo_db_storage'

module MongoDbClassifierBase
  def initialize(name)
    @storage = Ankusa::MongoDbStorage.new :host => CONFIG['mongo_db_host'], :port => CONFIG['mongo_db_port'], 
                                          :username => CONFIG['mongo_db_username'], :password => CONFIG['mongo_db_password'],
                                          :db => 'ankusa-test'
    super(name)
  end
end

class NBClassifierTest < Test::Unit::TestCase
  include MongoDbClassifierBase
  include NBClassifierBase
end

class KLClassifierTest < Test::Unit::TestCase
  include MongoDbClassifierBase
  include KLClassifierBase
end
