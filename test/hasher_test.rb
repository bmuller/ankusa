require File.join File.dirname(__FILE__), 'helper'

class HasherTest < Test::Unit::TestCase

  def test_stemming
    string = "Words word a the at fish fishing fishes? /^/  The at a of! @#$!"
    @text_hash = Ankusa::TextHash.new string
    @array = Ankusa::TextHash.new [string]

    assert_equal @text_hash.length, 2
    assert_equal @text_hash.word_count, 5

    assert_equal @array.length, 2
    assert_equal @array.word_count, 5
  end

  def test_atomization
    string = "Hello 123,45 My-name! is Robot14 123.45 @#$!"
    @array = Ankusa::TextHash.atomize string

    assert_equal %w{hello 123 45 my name is robot14 123 45}, @array
  end

  def test_valid_word
    assert !Ankusa::TextHash.valid_word?("accordingly")
    assert !Ankusa::TextHash.valid_word?("appropriate")
    assert Ankusa::TextHash.valid_word?("^*&@")
    assert Ankusa::TextHash.valid_word?("mother")
    assert !Ankusa::TextHash.valid_word?("21675")
    assert !Ankusa::TextHash.valid_word?("00000")
  end
end
