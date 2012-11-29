module Ankusa

  module Classifier
    attr_reader :classnames

    def initialize(storage)
      @storage = storage
      @storage.init_tables
      @classnames = @storage.classnames
    end

    # text can be either an array of strings or a string
    # klass is a symbol
    def train(klass, text)
      th = TextHash.new(text)
      th.each { |word, count|
        @storage.incr_word_count klass, word, count
        yield word, count if block_given?
      }
      @storage.incr_total_word_count klass, th.word_count
      doccount = (text.kind_of? Array) ? text.length : 1
      @storage.incr_doc_count klass, doccount
      @classnames << klass unless @classnames.include? klass
      # cache is now dirty of these vars
      @doc_count_totals = nil
      @vocab_sizes = nil
      th
    end

    # text can be either an array of strings or a string
    # klass is a symbol
    def untrain(klass, text)
      th = TextHash.new(text)
      th.each { |word, count|
        @storage.incr_word_count klass, word, -count
        yield word, count if block_given?
      }
      @storage.incr_total_word_count klass, -th.word_count
      doccount = (text.kind_of? Array) ? text.length : 1
      @storage.incr_doc_count klass, -doccount
      # cache is now dirty of these vars
      @doc_count_totals = nil
      @vocab_sizes = nil
      th
    end

    protected
    def get_word_probs(word, classnames)
      probs = Hash.new 0
      @storage.get_word_counts(word).each { |k,v| probs[k] = v if classnames.include? k }
      vs = vocab_sizes
      classnames.each { |cn|
        # if we've never seen the class, the word prob is 0
        next unless vs.has_key? cn

        # use a laplacian smoother
        probs[cn] = (probs[cn] + 1).to_f / (@storage.get_total_word_count(cn) + vs[cn]).to_f
      }
      probs
    end

    def doc_count_totals
      @doc_count_totals ||= @storage.doc_count_totals
    end

    def vocab_sizes
      @vocab_sizes ||= @storage.get_vocabulary_sizes
    end

  end

end
