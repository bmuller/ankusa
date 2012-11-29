require File.join File.dirname(__FILE__), 'helper'

module ClassifierBase
  def train
    @classifier.train :spam, "spam and great spam"   # spam:2 great:1
    @classifier.train :good, "words for processing" # word:1 process:1
    @classifier.train :good, "good word"            # word:1 good:1
  end

  def test_train
    counts = @storage.get_word_counts(:spam)
    assert_equal counts[:spam], 2
    counts = @storage.get_word_counts(:word)
    assert_equal counts[:good], 2
    assert_equal @storage.get_total_word_count(:good), 4
    assert_equal @storage.get_doc_count(:good), 2
    assert_equal @storage.get_total_word_count(:spam), 3
    assert_equal @storage.get_doc_count(:spam), 1
    totals = @storage.doc_count_totals
    assert_equal totals.values.inject { |x,y| x+y }, 3
    assert_equal totals[:spam], 1
    assert_equal totals[:good], 2

    vocab = @storage.get_vocabulary_sizes
    assert_equal vocab[:spam], 2
    assert_equal vocab[:good], 3
  end

  def teardown
    @storage.drop_tables
    @storage.close
  end
end


module NBClassifierBase
  include ClassifierBase

  def setup
    @classifier = Ankusa::NaiveBayesClassifier.new @storage
    train
  end

  def test_untrained
    @storage.reset

    string = "spam is tastey"

    hash = {:spam => 0, :good => 0}
    assert_equal hash, @classifier.classifications(string)
    assert_equal nil, @classifier.classify(string)
  end


  def test_probs
    spamlog = Math.log(3.0 / 5.0) + Math.log(1.0 / 5.0) + Math.log(2.0 / 5.0)
    goodlog = Math.log(1.0 / 7.0) + Math.log(1.0 / 7.0) + Math.log(3.0 / 5.0)

    # exponentiate
    spamex = Math.exp(spamlog)
    goodex = Math.exp(goodlog)

    # normalize
    spam = spamex / (spamex + goodex)
    good = goodex / (spamex + goodex)

    cs = @classifier.classifications("spam is tastey")
    assert_equal cs[:spam], spam
    assert_equal cs[:good], good

    cs = @classifier.log_likelihoods("spam is tastey")
    assert_equal cs[:spam], spamlog
    assert_equal cs[:good], goodlog

    @classifier.train :somethingelse, "this is something else entirely spam"
    cs = @classifier.classifications("spam is tastey", [:spam, :good])
    assert_equal cs[:spam], spam
    assert_equal cs[:good], good

    # test for class we didn't train on
    cs = @classifier.classifications("spam is super tastey if you are a zombie", [:spam, :nothing])
    assert_equal cs[:nothing], 0
  end

  def test_prob_result
    cs = @classifier.classifications("spam is tastey").sort_by { |c| -c[1] }.first.first
    klass = @classifier.classify("spam is tastey")
    assert_equal cs, klass
    assert_equal klass, :spam
  end
end


module KLClassifierBase
  include ClassifierBase

  def setup
    @classifier = Ankusa::KLDivergenceClassifier.new @storage
    train
  end

  def test_distances
    ds = @classifier.distances("spam is tastey")
    thprob_spam = 1.0 / 2.0
    thprob_tastey = 1.0 / 2.0

    train_prob_spam = (2 + 1).to_f / (3 + 2).to_f
    train_prob_tastey = (0 + 1).to_f / (3 + 2).to_f
    dist = thprob_spam * Math.log(thprob_spam / train_prob_spam)
    dist += thprob_tastey * Math.log(thprob_tastey / train_prob_tastey)
    assert_equal ds[:spam], dist

    train_prob_spam = 1.0 / (4 + 3).to_f
    train_prob_tastey = 1.0 / (4 + 3).to_f
    dist = thprob_spam * Math.log(thprob_spam / train_prob_spam)
    dist += thprob_tastey * Math.log(thprob_tastey / train_prob_tastey)
    assert_equal ds[:good], dist
  end

  def test_distances_result
    cs = @classifier.distances("spam is tastey").sort_by { |c| c[1] }.first.first
    klass = @classifier.classify("spam is tastey")
    assert_equal cs, klass
    assert_equal klass, :spam

    # assert distance from class we didn't train with is Infinity (1.0/0.0 is a way to get at Infinity)
    cs = @classifier.distances("spam is tastey", [:spam, :nothing])
    assert_equal cs[:nothing], (1.0/0.0)
  end
end
