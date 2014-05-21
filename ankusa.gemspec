$:.push File.expand_path("../lib", __FILE__)
require "ankusa/version"

Gem::Specification.new do |s|
  s.name = "ankusa"
  s.version = Ankusa::VERSION
  s.authors = ["Brian Muller"]
  s.description = "Text classifier with HBase, Cassandra, or Mongo storage"
  s.summary = "Text classifier in Ruby that uses Hadoop's HBase, Cassandra, or Mongo for storage"
  s.email = "bamuller@gmail.com"
  s.files = `git ls-files`.split($/)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.homepage = "https://github.com/bmuller/ankusa"
  s.require_paths = ["lib"]
  s.add_dependency('fast-stemmer', '>= 1.0.0')
  s.add_development_dependency("rake")
  s.add_development_dependency("mongo")
  s.requirements << "Either hbaserb >= 0.0.3 or cassandra >= 0.7"
  s.rubyforge_project = "ankusa"
end
