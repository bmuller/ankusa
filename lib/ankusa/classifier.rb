module Ankusa

  class Classifier
    attr_reader :classnames

    def initialize(hbase_client, frequency_tablename="ankusa_word_frequencies", summary_tablename="ankusa_summary")
      @hbase = hbase_client
      @ftablename = frequency_tablename
      @stablename = summary_tablename
      init_tables
      @classnames = refresh_classnames
    end
 
    def train(klass, text)
      th = TextHash.new(text)
      th.each { |word, count|
        freq_table.atomic_increment word, "classes:#{klass.to_s}", count
      }
      summary_table.atomic_increment klass, "totals:wordcount", th.word_count
      summary_table.atomic_increment klass, "totals:doccount"
      @classnames << klass if not @classnames.include? klass
    end

    def untrain(klass, text)
      th = TextHash.new(text)
      th.each { |word, count|
        freq_table.atomic_increment word, "classes:#{klass.to_s}", -count
      }
      summary_table.atomic_increment klass, "totals:wordcount", -th.word_count
      summary_table.atomic_increment klass, "totals:doccount", -1
    end

    def classify(text)
      # return the most probable class
      classifications(text).sort { |o,t| o[1] <=> t[1] }.first.first
    end
    
    def classifications(text)
      classes = {}
      results = {}
      @classnames.each { |k| 
        classes[k] = NBClass.new k, summary_table, freq_table
        result[k] = 0 
      }

      TextHash.new(text).each { |word,count|
        probs = get_counts(word)
        @classnames.each { |k|
          result[k] += Math.log(probs[k] / classes[k].word_count)
        }
      }
     
      @classnames.each { |k|
        result[k] += Math.log(classes[k].doc_count / doc_count_total)
      }

      # todo
      # normalize logs to make probs
      # implement get_counts

      result
    end

    # get all classes
    def refresh_classnames
      cs = []
      summary_table.create_scanner("", "totals") { |row|
        cs << row.row.intern
      }
      cs
    end

    def drop_tables
      freq_table.delete
      summary_table.delete      
      @stable = nil
      @ftable = nil
    end

    def reset
      drop_tables
      init_tables
    end

    def doc_count_total
      total = 0
      summary_table.create_scanner("", "totals:doccount") { |row|
        total += row.columns["totals:doccount"].to_i64
      }
      total
    end
    
    protected
    def init_tables
      if not @hbase.has_table? @ftablename
        @hbase.create_table @ftablename, "classes", "total"
      end

      if not @hbase.has_table? @stablename
        @hbase.create_table @stablename, "totals"
      end
    end

    def summary_table
      @stable ||= @hbase.get_table @stablename
    end

    def freq_table
      @ftable ||= @hbase.get_table @ftablename
    end
  end

end
