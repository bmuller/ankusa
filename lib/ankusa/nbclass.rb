module Ankusa

  class NBClass
    attr_reader :doc_count, :word_count

    def initialize(name, summary_table, freq_table)
      @name = name
      @summary_table = summary_table
      @freq_table = freq_table
      @word_count = @summary_table.get(@name, "totals:wordcount").first.to_i64.to_f
      @doc_count = @summary_table.get(@name, "totals:doccount").first.to_i64.to_f
    end
  end

end
