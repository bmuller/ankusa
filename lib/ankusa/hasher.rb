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
      if text.kind_of? Array
        text.each { |t| add_text t }
      else
        # replace dashes with spaces, then get rid of non-word/non-space characters, 
        # then split by space to get words
        words = TextHash.atomize text
        words.each { |word| add_word(word) if TextHash.valid_word?(word) }
      end
      self
    end

    def add_word(word)
      @word_count += 1
      key = word.stem.intern
      store key, fetch(key, 0)+1
    end

    def self.atomize(text)
      text.to_ascii.tr('-', ' ').gsub(/[^\w\s]/," ").split.map { |w| w.downcase }
    end

    # word should be only alphanum chars at this point
    def self.valid_word?(word)
      return false if Ankusa::STOPWORDS.include? word
      return false if word.length < 3
      return false if word.numeric?
      true
    end

  end

end
