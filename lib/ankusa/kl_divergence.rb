module Ankusa

  class KLDivergenceClassifier
    include Classifier

    def classify(text, classes=nil)
      # return the class with the least distance from the word
      # distribution of the given text
      distances(text, classes).sort_by { |c| c[1] }.first.first
    end
    

    # Classes is an array of classes to look at
    def distances(text, classnames=nil)
      classnames ||= @classnames
      distances = Hash.new 0

      th = TextHash.new(text)
      th.each { |word, count|
        thprob = count.to_f / th.length.to_f
        probs = get_word_probs(word, classnames)
        classnames.each { |k| 
          distances[k] += (thprob * Math.log(thprob / probs[k]) * count) 
        }
      }

      distances
    end
  end

end
