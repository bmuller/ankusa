require File.join File.dirname(__FILE__), 'helper'

class ClassifierTest < Test::Unit::TestCase
  def initialize(name)
    @freq_tablename = "ankusa_word_frequencies_test"
    @sum_tablename = "ankusa_summary_test"    
    super(name)
  end

  def setup
    @hbase = HBaseRb::Client.new CONFIG['hbase_host'], CONFIG['hbase_port']
    @ankusa = Ankusa::Classifier.new @hbase, @freq_tablename, @sum_tablename
    @freq_table = @hbase.get_table(@freq_tablename)
    @sum_table = @hbase.get_table(@sum_tablename)
  end
  
  def test_train
    @ankusa.train :spam, "spam and more spam"
    @ankusa.train :good, "words for processing"
    @ankusa.train :good, "good word"
    assert_equal @freq_table.get(:spam, "classes:spam").first.to_i64, 2
    assert_equal @freq_table.get(:word, "classes:good").first.to_i64, 2
    assert_equal @sum_table.get(:good, "totals:wordcount").first.to_i64, 4
    assert_equal @sum_table.get(:good, "totals:doccount").first.to_i64, 2
    assert_equal @sum_table.get(:spam, "totals:wordcount").first.to_i64, 2
    assert_equal @sum_table.get(:spam, "totals:doccount").first.to_i64, 1
  end

  def teardown
    @ankusa.drop_tables
    @hbase.close
  end
end
