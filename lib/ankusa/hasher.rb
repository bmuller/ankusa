require 'fast_stemmer'
require 'ankusa/stopwords'

module Ankusa

  class TextHash < Hash 
    attr_reader :word_count

    def initialize(text=nil)
      super 0
      @word_count = 0
      add_text(text) if not text.nil?
    end

    def add_text(text)
      # replace dashes with spaces, then get rid of non-word/non-space characters, 
      # then split by space to get words
      words = text.tr('-', ' ').gsub(/[^\w\s]/,"").split
      words.each { |word| add_word word }
      self
    end

    def add_word(word)
      word = word.downcase
      if not Ankusa::STOPWORDS.include? word
        @word_count += 1
        key = word.intern
        store key, fetch(key, 0)+1
      end
    end
  end

end
