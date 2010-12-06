module Ankusa

  class Classifier
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
      @classnames << klass if not @classnames.include? klass
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

    def classify(text, classes=nil)
      # return the most probable class
      log_likelihoods(text, classes).sort_by { |c| -c[1] }.first.first
    end
    
    # Classes is an array of classes to look at
    def classifications(text, classnames=nil)
      result = log_likelihoods text, classnames
      result.keys.each { |k|
        result[k] = Math.exp result[k] 
      }

      # normalize to get probs
      sum = result.values.inject { |x,y| x+y }
      result.keys.each { |k| result[k] = result[k] / sum }
      result
    end

    # Classes is an array of classes to look at
    def log_likelihoods(text, classnames=nil)
      classnames ||= @classnames
      result = Hash.new 0

      TextHash.new(text).each { |word, count|
        probs = get_word_probs(word, classnames)
        classnames.each { |k| result[k] += (Math.log(probs[k]) * count) }
      }

      # add the prior and exponentiate
      doc_counts = doc_count_totals.select { |k,v| classnames.include? k }.map { |k,v| v }
      doc_count_total = (doc_counts.inject { |x,y| x+y } + classnames.length).to_f
      classnames.each { |k| 
        result[k] += Math.log((@storage.get_doc_count(k) + 1).to_f / doc_count_total) 
      }
      
      result
    end

    protected
    def get_word_probs(word, classnames)
      probs = Hash.new 0
      @storage.get_word_counts(word).each { |k,v| probs[k] = v if classnames.include? k }
      vs = vocab_sizes
      classnames.each { |cn| 
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
