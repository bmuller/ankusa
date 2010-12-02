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
      if not @hbase.has_table? @ftablename
        @hbase.create_table @ftablename, "classes", "total"
      end

      if not @hbase.has_table? @stablename
        @hbase.create_table @stablename, "totals"
      end
    end

    def get_word_counts(word)
      counts = Hash.new(0)
      row = freq_table.get_row(word)
      return counts if row.length == 0

      row.first.columns.each { |colname, cell|
        classname = colname.split(':')[1].intern
        counts[classname] = cell.to_i64.to_f
      }

      counts
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
      freq_table.atomic_increment word, "classes:#{klass.to_s}", count
    end

    def incr_total_word_count(klass, count)
      @klass_word_counts[klass] = summary_table.atomic_increment klass, "totals:wordcount", count
    end

    def incr_doc_count(klass, count)
      @klass_doc_counts[klass] = summary_table.atomic_increment klass, "totals:doccount", count
    end

    def doc_count_total
      total = 0
      summary_table.create_scanner("", "totals:doccount") { |row|
        total += row.columns["totals:doccount"].to_i64
      }
      total
    end

    def close
      @hbase.close
    end

    protected
    def summary_table
      @stable ||= @hbase.get_table @stablename
    end

    def freq_table
      @ftable ||= @hbase.get_table @ftablename
    end

  end

end
