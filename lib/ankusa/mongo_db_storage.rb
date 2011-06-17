require 'mongo'
#require 'bson_ext'

module Ankusa
  class MongoDbStorage

    def initialize(opts={})
      options = { :host => "localhost", :port => 27017, :db => "ankusa",
                  :frequency_tablename => "word_frequencies", :summary_tablename => "summary"
                }.merge(opts)

      @db = Mongo::Connection.new(options[:host], options[:port]).db(options[:db])
      @db.authenticate(options[:username], options[:password]) if options[:password]

      @ftablename = options[:frequency_tablename]
      @stablename = options[:summary_tablename]

      @klass_word_counts = {}
      @klass_doc_counts = {}

      init_tables
    end

    def init_tables
      @db.create_collection(@ftablename) unless @db.collection_names.include?(@ftablename)
      @db.create_collection(@stablename) unless @db.collection_names.include?(@stablename)
    end

    def drop_tables
      @db.drop_collection(@ftablename)
      @db.drop_collection(@stablename)
    end

    def classnames
      cs = []
      []
    end

    def reset
      drop_tables
      init_tables
    end

    def incr_word_count(klass, word, count)
      word_doc = freq_table.find_one(:word => word)
      if word_doc
        freq_table.update({'_id' => word_doc['_id'] }, { '$inc' => {klass => count} })
      else
        freq_table.insert(:word => word, klass => count)
        #TODO: increment if it's new decrement if final count == 0
        increment_summary_klass(klass, 'vocabulary_size', 1)
      end
    end

    def incr_total_word_count(klass, count)
      increment_summary_klass(klass, 'word_count', count)
    end

    def incr_doc_count(klass, count)
      increment_summary_klass(klass, 'doc_count', count)
    end

    def get_word_counts(word)
      counts = Hash.new(0)

      word_doc = freq_table.find_one({:word => word})
      if word_doc
        word_doc.delete("_id")
        word_doc.delete("word")
        #convert keys to symbols 
        counts.merge!(word_doc.inject({}){|h, (k, v)| h[(k.to_sym rescue k) || k] = v; h}) 
      end

      counts
    end

    def get_total_word_count(klass)
      klass_doc = summary_table.find_one(:klass => klass)
      klass_doc ? klass_doc['word_count'].to_f : 0.0
    end

    def doc_count_totals
      count = Hash.new(0)

      summary_table.find.each do |doc|
        count[ doc['klass'] ] = doc['doc_count']
      end

      count
    end

    def get_vocabulary_sizes
      count = Hash.new(0)

      summary_table.find.each do |doc|
        count[ doc['klass'] ] = doc['vocabulary_size']
      end

      count
    end

    def get_doc_count(klass)
      klass_doc = summary_table.find_one(:klass => klass) 
      klass_doc ? klass_doc['doc_count'].to_f : 0.0
    end

    def close
    end

    private
    def summary_table
      @stable ||= @db[@stablename]
    end

    def freq_table
      @ftable ||= @db[@ftablename]
    end

    def increment_summary_klass(klass, field, count)
      klass_doc = summary_table.find_one(:klass => klass)
      if klass_doc
        summary_table.update({'_id' => klass_doc['_id'] }, { '$inc' => {field => count} })
      else
        summary_table.insert(:klass => klass, field => count)
      end
    end

  end
end
