require 'cassandra/0.7'

#
# At the moment you'll have to do:
#
# create keyspace ankusa with replication_factor = 1
#
# from the cassandra-cli. This should be fixed with new release candidate for
# cassandra
#
module Ankusa

  class CassandraStorage
    attr_reader :cassandra

    #
    # Necessary to set max classes since current implementation of ruby
    # cassandra client doesn't support table scans. Using crufty get_range
    # method at the moment.
    #
    def initialize(host='127.0.0.1', port=9160, keyspace = 'ankusa', max_classes = 100)
      @cassandra  = Cassandra.new('system', "#{host}:#{port}")
      @klass_word_counts, @klass_doc_counts = {}
      @keyspace    = keyspace
      @max_classes = max_classes
      init_tables
    end

    #
    # Fetch the names of the distinct classes for classification:
    # eg. :spam, :good, etc
    #
    def classnames
      @cassandra.get_range(:totals, {:start => '', :finish => '', :count => @max_classes}).inject([]) do |cs, key_slice|
        cs << key_slice.key.to_sym
      end
    end

    def reset
      drop_tables
      init_tables
    end

    #
    # Drop ankusa keyspace, reset internal caches
    #
    # FIXME: truncate doesn't work with cassandra-beta2
    #
    def drop_tables
      @cassandra.truncate!('classes')
      @cassandra.truncate!('totals')
      @cassandra.drop_keyspace(@keyspace)
      @klass_word_counts, @klass_doc_counts = {}
    end


    #
    # Create required keyspace and column families
    #
    def init_tables
      # Do nothing if keyspace already exists
      if @cassandra.keyspaces.include?(@keyspace)
        @cassandra.keyspace = @keyspace
      else
        freq_table    = Cassandra::ColumnFamily.new({:keyspace => @keyspace, :name => "classes"}) # word  => {classname => count}
        summary_table = Cassandra::ColumnFamily.new({:keyspace => @keyspace, :name => "totals"})  # class => {wordcount => count}
        ks_def = Cassandra::Keyspace.new({
            :name               => @keyspace,
            :strategy_class     => 'org.apache.cassandra.locator.SimpleStrategy',
            :replication_factor => 1,
            :cf_defs            => [freq_table, summary_table] 
          })
        @cassandra.add_keyspace ks_def
        @cassandra.keyspace = @keyspace
      end
    end

    #
    # Fetch hash of word counts as a single row from cassandra.
    # Here column_name is the class and column value is the count
    #
    def get_word_counts(word)
      # fetch all (class,count) pairs for a given word
      row = @cassandra.get(:classes, word.to_s)
      return row.to_hash if row.empty?
      row.inject({}){|counts, col| counts[col.first.to_sym] = [col.last.to_f,0].max; counts}
    end

    #
    # Does a table 'scan' of summary table pulling out the 'vocabsize' column
    # from each row. Generates a hash of (class, vocab_size) key value pairs
    #
    def get_vocabulary_sizes
      get_summary "vocabsize"
    end

    #
    # Fetch total word count for a given class and cache it
    #
    def get_total_word_count(klass)
      @klass_word_counts[klass] = @cassandra.get(:totals, klass.to_s, "wordcount").values.last.to_f
    end

    #
    # Fetch total documents for a given class and cache it
    #
    def get_doc_count(klass)
      @klass_doc_counts[klass] = @cassandra.get(:totals, klass.to_s, "doc_count").values.last.to_f
    end

    #
    # Increment the count for a given (word,class) pair. Evidently, cassandra
    # does not support atomic increment/decrement. Psh. HBase uses ZooKeeper to
    # implement atomic operations, ain't it special?
    #
    def incr_word_count(klass, word, count)
      # Only wants strings
      klass = klass.to_s
      word  = word.to_s

      prior_count = @cassandra.get(:classes, word, klass).values.last.to_i
      new_count   = prior_count + count
      @cassandra.insert(:classes, word, {klass => new_count.to_s})

      if (prior_count == 0 && count > 0)
        #
        # we've never seen this word before and we're not trying to unlearn it
        #
        vocab_size = @cassandra.get(:totals, klass, "vocabsize").values.last.to_i
        vocab_size += 1
        @cassandra.insert(:totals, klass, {"vocabsize" => vocab_size.to_s})
      elsif new_count == 0
        #
        # we've seen this word before but we're trying to unlearn it
        #
        vocab_size = @cassandra.get(:totals, klass, "vocabsize").values.last.to_i
        vocab_size -= 1
        @cassandra.insert(:totals, klass, {"vocabsize" => vocab_size.to_s})
      end
      new_count
    end

    #
    # Increment total word count for a given class by 'count'
    #
    def incr_total_word_count(klass, count)
      klass = klass.to_s
      wordcount = @cassandra.get(:totals, klass, "wordcount").values.last.to_i
      wordcount += count
      @cassandra.insert(:totals, klass, {"wordcount" => wordcount.to_s})
      @klass_word_counts[klass.to_sym] = wordcount
    end

    #
    # Increment total document count for a given class by 'count'
    #
    def incr_doc_count(klass, count)
      klass = klass.to_s
      doc_count = @cassandra.get(:totals, klass, "doc_count").values.last.to_i
      doc_count += count
      @cassandra.insert(:totals, klass, {"doc_count" => doc_count.to_s})
      @klass_doc_counts[klass.to_sym] = doc_count
    end

    def doc_count_totals
      get_summary "doc_count"
    end

    #
    # Doesn't do anything
    #
    def close
    end

    protected

    #
    # Fetch 100 rows from summary table, yes, increase if necessary
    #
    def get_summary(name)
      counts = {}
      @cassandra.get_range(:totals, {:start => '', :finish => '', :count => @max_classes}).each do |key_slice|
        # keyslice is a clunky thrift object, map into a ruby hash
        row = key_slice.columns.inject({}){|hsh, c| hsh[c.column.name] = c.column.value; hsh}
        counts[key_slice.key.to_sym] = row[name].to_f
      end
      counts
    end

  end

end
