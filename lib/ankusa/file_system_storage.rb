require File.dirname(__FILE__)+'/memory_storage'

module Ankusa

  class FileSystemStorage < MemoryStorage

    def initialize file
      @file = file
      init_tables()
    end

    def reset
      @freqs = {}
      @total_word_counts = Hash.new(0)
      @total_doc_counts = Hash.new(0)
      @klass_word_counts = {}
      @klass_doc_counts = {}
    end
    
    def drop_tables
      File.delete(@file) rescue Errno::ENOENT
      reset
    end

    def init_tables
      data = {}
      begin
      File.open(@file) do |f|
        data = Marshal.load(f)
      end
      @freqs = data[:freqs]
      @total_word_counts = data[:total_word_counts]
      @total_doc_counts = data[:total_doc_counts]
      @klass_word_counts = data[:klass_word_counts]
      @klass_doc_counts = data[:klass_word_counts]
      rescue Errno::ENOENT
        reset
      end
    end

    def save file = nil 
      @file = file.nil? ? @file : file
      data = { 	:freqs => @freqs,
		:total_word_counts => @total_word_counts,
		:total_doc_counts => @total_doc_counts,
		:klass_word_counts => @klass_word_counts,
		:klass_doc_counts => @klass_doc_counts }
      File.open(@file, 'w+') do |f|
        Marshal.dump(data, f)
      end
    end

  end

end
