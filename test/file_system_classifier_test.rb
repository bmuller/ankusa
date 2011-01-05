require File.join File.dirname(__FILE__), 'classifier_base'
require 'ankusa/file_system_storage'

module FileSystemClassifierBase
  def initialize(name)
    @storage = Ankusa::FileSystemStorage.new CONFIG['file_system_storage_file']
    super name
  end

  def test_storage
    # train will be called in setup method, now reload storage and test training
    @storage.save
    @storage = Ankusa::FileSystemStorage.new CONFIG['file_system_storage_file']
    test_train
  end
end

class NBMemoryClassifierTest < Test::Unit::TestCase
  include FileSystemClassifierBase
  include NBClassifierBase
end


class KLMemoryClassifierTest < Test::Unit::TestCase
  include FileSystemClassifierBase
  include KLClassifierBase
end
