require File.join File.dirname(__FILE__), 'classifier_base'

class MemoryClassifierTest < Test::Unit::TestCase
  include ClassifierBase

  def initialize(name)
    @storage = Ankusa::MemoryStorage.new
    super name
  end
end
