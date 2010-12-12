require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

desc "Create documentation"
Rake::RDocTask.new("doc") { |rdoc|
  rdoc.title = "HBaseRb - Naive Bayes classifier with HBase storage"
  rdoc.rdoc_dir = 'docs'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

desc "Run all unit tests with memory storage"
Rake::TestTask.new("test_memory") { |t|
  t.libs << "lib"
  t.test_files = FileList['test/hasher_test.rb', 'test/memory_classifier_test.rb']
  t.verbose = true
}

desc "Run all unit tests with HBase storage"
Rake::TestTask.new("test_hbase") { |t|
  t.libs << "lib"
  t.test_files = FileList['test/hasher_test.rb', 'test/memory_hbase_test.rb']
  t.verbose = true
}

desc "Run all unit tests with Cassandra storage"
Rake::TestTask.new("test_cassandra") { |t|
  t.libs << "lib"
  t.test_files = FileList['test/hasher_test.rb', 'test/cassandra_classifier_test.rb']
  t.verbose = true
}

spec = Gem::Specification.new do |s|
  s.name = "ankusa"
  s.version = "0.0.7"
  s.authors = ["Brian Muller"]
  s.date = %q{2010-12-12}
  s.description = "Text classifier with HBase or Cassandra storage"
  s.summary = "Text classifier in Ruby that uses Hadoop's HBase or Cassandra for storage"
  s.email = "brian.muller@livingsocial.com"
  s.files = FileList["lib/**/*", "[A-Z]*", "Rakefile", "docs/**/*"]
  s.homepage = "https://github.com/livingsocial/ankusa"
  s.require_paths = ["lib"]
  s.add_dependency('fast-stemmer', '>= 1.0.0')
  s.requirements << "Either hbaserb >= 0.0.3 or cassandra >= 0.7"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Default task: builds gem and runs tests"
task :default => [ :gem, :test ]
