require 'fast_stemmer'
require 'ankusa/stopwords'

module Ankusa

  class TextHash < Hash
    attr_reader :word_count

    def initialize(text=nil, stem=true)
      super 0
      @word_count = 0
      @stem = stem
      add_text(text) unless text.nil?
    end

    def self.atomize(text)
      text.downcase.to_ascii.tr('-', ' ').gsub(/[^\w\s]/," ").split
    end

    # word should be only alphanum chars at this point
    def self.valid_word?(word)
      not (Ankusa::STOPWORDS.include?(word) || word.length < 3 || self.numeric_word?(word))
    end

    def add_text(text)
      if text.instance_of? Array
        text.each { |t| add_text t }
      else
        # replace dashes with spaces, then get rid of non-word/non-space characters,
        # then split by space to get words
        words = TextHash.atomize text
        words.each { |word| add_word(word) if TextHash.valid_word?(word) }
      end
      self
    end

    protected

    def add_word(word)
      @word_count += 1
      word = word.stem if @stem
      key = word.intern
      store key, fetch(key, 0)+1
    end

    # Due to the character filtering that takes place in atomisation
    # this method should never received something that could be a
    # negative number, float etc.
    # Therefore we can dispense with the SLOW Float(word) method and
    # just do a simple regex.
    def self.numeric_word?(word)
      word.match(/[\d]+/)
    end
  end

end
