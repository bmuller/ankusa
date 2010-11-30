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

    @ankusa.train :spam, "spam and great spam"   # spam:2 great:1
    @ankusa.train :good, "words for processing" # word:1 process:1
    @ankusa.train :good, "good word"            # word:1 good:1
  end

  def test_train
    assert_equal @freq_table.get(:spam, "classes:spam").first.to_i64, 2
    assert_equal @freq_table.get(:word, "classes:good").first.to_i64, 2
    assert_equal @sum_table.get(:good, "totals:wordcount").first.to_i64, 4
    assert_equal @sum_table.get(:good, "totals:doccount").first.to_i64, 2
    assert_equal @sum_table.get(:spam, "totals:wordcount").first.to_i64, 3
    assert_equal @sum_table.get(:spam, "totals:doccount").first.to_i64, 1
  end

  def test_probs
    spamlog = Math.log(2.0/3.0) + Math.log(Ankusa::SMALL_PROB / 3.0) + Math.log(1.0 / 3.0)
    goodlog = Math.log(Ankusa::SMALL_PROB / 4.0) + Math.log(Ankusa::SMALL_PROB / 4.0) + Math.log(2.0 / 3.0)
    spamprob = spamlog / (spamlog + goodlog)
    goodprob = goodlog / (spamlog + goodlog)

    cs = @ankusa.classifications("spam is tastey")
    assert_equal cs[:spam], spamprob
    assert_equal cs[:good], goodprob
  end
  
  def teardown
    @ankusa.drop_tables
    @hbase.close
  end
end
