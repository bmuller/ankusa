require 'hbaserb'

module Ankusa

  class HBaseStorage
    attr_reader :hbase

    def initialize(host='localhost', port=9090, frequency_tablename="ankusa_word_frequencies", summary_tablename="ankusa_summary")
      @hbase = HBaseRb::Client.new host, port
      @ftablename = frequency_tablename
      @stablename = summary_tablename
      @klass_word_counts = {}
      @klass_doc_counts = {}
      init_tables
    end

    def classnames
      cs = []
      summary_table.create_scanner("", "totals") { |row|
        cs << row.row.intern
      }
      cs
    end

    def reset
      drop_tables
      init_tables
    end
    
    def drop_tables
      freq_table.delete
      summary_table.delete
      @stable = nil
      @ftable = nil
      @klass_word_counts = {}
      @klass_doc_counts = {}
    end

    def init_tables
      unless @hbase.has_table? @ftablename
        @hbase.create_table @ftablename, "classes", "total"
      end

      unless @hbase.has_table? @stablename
        @hbase.create_table @stablename, "totals"
      end
    end

    def get_word_counts(word)
      counts = Hash.new(0)
      row = freq_table.get_row(word)
      return counts if row.length == 0

      row.first.columns.each { |colname, cell|
        classname = colname.split(':')[1].intern
        # in case untrain has been called too many times
        counts[classname] = [cell.to_i64.to_f, 0].max
      }

      counts
    end

    def get_vocabulary_sizes
      get_summary "totals:vocabsize"
    end

    def get_total_word_count(klass)
      @klass_word_counts.fetch(klass) {
        @klass_word_counts[klass] = summary_table.get(klass, "totals:wordcount").first.to_i64.to_f
      }
    end
    
    def get_doc_count(klass)
      @klass_doc_counts.fetch(klass) {
        @klass_doc_counts[klass] = summary_table.get(klass, "totals:doccount").first.to_i64.to_f
      }
    end

    def incr_word_count(klass, word, count)
      size = freq_table.atomic_increment word, "classes:#{klass.to_s}", count
      # if this is a new word, increase the klass's vocab size.  If the new word
      # count is 0, then we need to decrement our vocab size
      if size == count
        summary_table.atomic_increment klass, "totals:vocabsize"
      elsif size == 0
        summary_table.atomic_increment klass, "totals:vocabsize", -1        
      end
      size
    end

    def incr_total_word_count(klass, count)
      @klass_word_counts[klass] = summary_table.atomic_increment klass, "totals:wordcount", count
    end

    def incr_doc_count(klass, count)
      @klass_doc_counts[klass] = summary_table.atomic_increment klass, "totals:doccount", count
    end

    def doc_count_totals
      get_summary "totals:doccount"
    end

    def close
      @hbase.close
    end

    protected
    def get_summary(name)
      counts = Hash.new 0
      summary_table.create_scanner("", name) { |row|
        counts[row.row.intern] = row.columns[name].to_i64
      }
      counts
    end

    def summary_table
      @stable ||= @hbase.get_table @stablename
    end

    def freq_table
      @ftable ||= @hbase.get_table @ftablename
    end

  end

end
