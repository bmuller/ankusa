module Ankusa
  SMALL_PROB = 0.0001

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
      result = {}
      @classnames.each { |k| 
        classes[k] = NBClass.new k, summary_table, freq_table
        result[k] = 0 
      }

      TextHash.new(text).each { |word,count|
        probs = get_word_probs(word, classes)
        @classnames.each { |k| result[k] += Math.log(probs[k]) }
      }
     
      @classnames.each { |k| result[k] += Math.log(classes[k].doc_count / doc_count_total) }

      result.keys.each { |k| result[k] = Math.exp(result[k]) }
      sum = result.values.inject { |x,y| x+y }
      result.keys.each { |klass|
        result[klass] = result[klass] / sum
      }

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
    def get_word_probs(word, classes)
      probs = {}
      @classnames.each { |cn| probs[cn] = Ankusa::SMALL_PROB / classes[cn].word_count }
      row = freq_table.get_row(word)
      return probs if row.length == 0

      row.first.columns.each { |colname, cell|
        classname = colname.split(':')[1].intern
        probs[classname] = cell.to_i64.to_f / classes[classname].word_count
      }
      probs
    end

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
