require File.join File.dirname(__FILE__), 'classifier_base'

class MemoryClassifierBase < Test::Unit::TestCase
  def initialize(name)
    @storage = Ankusa::MemoryStorage.new
    super name
  end
end

class NBMemoryClassifierTest < MemoryClassifierBase
  include NBClassifierBase
end


class KLMemoryClassifierTest < MemoryClassifierBase
  include KLClassifierBase
end
