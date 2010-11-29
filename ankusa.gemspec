Gem::Specification.new do |s|
  s.name = "ankusa"
  s.version = "0.0.1"
  s.authors = ["Brian Muller"]
  s.date = %q{2010-11-29}
  s.description = "Naive Bayes classifier with HBase storage"
  s.summary = "Naive Bayes classifier in Ruby that uses Hadoop's HBase for storage"
  s.email = "brian.muller@livingsocial.com"
  s.files = [
    "lib/ankusa.rb",
    "lib/ankusa/classifier.rb",
  ]
  s.homepage = "https://github.com/livingsocial/ankusa"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.5"
  s.add_dependency('hbaserb', '>= 0.0.1')
  s.add_dependency('fast-stemmer', '>= 1.0.0')
end