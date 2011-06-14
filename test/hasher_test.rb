require File.join File.dirname(__FILE__), 'helper'

class HasherTest < Test::Unit::TestCase
  def setup
    @text_hash = Ankusa::TextHash.new "Words word a the at fish fishing fishes? /^/  The at a of! @#$!"
    @array = [@text_hash]
  end

  def test_stemming
    assert_equal @text_hash.length, 2
    assert_equal @text_hash.word_count, 5

    if @array.respond_to? :each
      @array.each do |a|
        assert_equal a.length, 2
        assert_equal a.word_count, 5
      end
    end
  end

  def test_valid_word
    assert_nil Ankusa::TextHash.valid_word? "accordingly"
    assert_nil Ankusa::TextHash.valid_word? "appropriate"
    assert Ankusa::TextHash.valid_word? "^*&@"
    assert Ankusa::TextHash.valid_word? "mother"
    assert Ankusa::TextHash.valid_word? "21675"
  end

  def teardown
    @text_hash, @array = nil
  end
end
