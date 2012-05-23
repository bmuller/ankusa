$:.push File.expand_path("../lib", __FILE__)
require "ankusa/version"
require "rake"
require "date"

Gem::Specification.new do |s|
  s.name = "ankusa"
  s.version = Ankusa::VERSION
  s.authors = ["Brian Muller"]
  s.date = Date.today.to_s
  s.description = "Text classifier with HBase, Cassandra, or Mongo storage"
  s.summary = "Text classifier in Ruby that uses Hadoop's HBase, Cassandra, or Mongo for storage"
  s.email = "brian.muller@livingsocial.com"
  s.files = FileList["lib/**/*", "[A-Z]*", "Rakefile", "docs/**/*"]
  s.homepage = "https://github.com/livingsocial/ankusa"
  s.require_paths = ["lib"]
  s.add_dependency('fast-stemmer', '>= 1.0.0')
  s.requirements << "Either hbaserb >= 0.0.3 or cassandra >= 0.7"
  s.rubyforge_project = "ankusa"
end
