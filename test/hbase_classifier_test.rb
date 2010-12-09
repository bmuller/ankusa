require File.join File.dirname(__FILE__), 'classifier_base'

class HBaseClassifierBase < Test::Unit::TestCase
  def initialize(name)
    @freq_tablename = "ankusa_word_frequencies_test"
    @sum_tablename = "ankusa_summary_test"    
    @storage = Ankusa::HBaseStorage.new CONFIG['hbase_host'], CONFIG['hbase_port'], @freq_tablename, @sum_tablename    
    @freq_table = @storage.hbase.get_table(@freq_tablename)
    @sum_table = @storage.hbase.get_table(@sum_tablename)
    super(name)
  end
end

class NBClassifierTest < HBaseClassifierBase
  include NBClassifierBase
end

class KLClassifierTest < HBaseClassifierBase
  include KLClassifierBase
end
