require 'stemmer'

module Ankusa

  class Classifier
    def initialize(hbase_client)
      @hbase = hbase_client
    end
 
    def train(klass, text)
      # word.stem
    end

    def untrain(klass, text)
    end

    def classify(text)
    end
    
    def classes(text)
    end
  end

end
