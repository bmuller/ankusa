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
      freq_table[word][klass] ||= 0
      freq_table[word][klass] += count
    end


    private
    def summary_table
      @stable ||= @db[@stablename]
    end

    def freq_table
      @ftable ||= @db[@ftablename]
    end


  end
end
