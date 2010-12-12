require File.join File.dirname(__FILE__), 'classifier_base'
require 'ankusa/memory_storage'

module MemoryClassifierBase
  def initialize(name)
    @storage = Ankusa::MemoryStorage.new
    super name
  end
end

class NBMemoryClassifierTest < Test::Unit::TestCase
  include MemoryClassifierBase
  include NBClassifierBase
end


class KLMemoryClassifierTest < Test::Unit::TestCase
  include MemoryClassifierBase
  include KLClassifierBase
end
