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

# Run the unit tests
desc "Run all unit tests"
Rake::TestTask.new("test") { |t|
  t.libs << "lib"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
}

spec = Gem::Specification.new do |s|
  s.name = "ankusa"
  s.version = "0.0.5"
  s.authors = ["Brian Muller"]
  s.date = %q{2010-12-03}
  s.description = "Naive Bayes classifier with HBase storage"
  s.summary = "Naive Bayes classifier in Ruby that uses Hadoop's HBase for storage"
  s.email = "brian.muller@livingsocial.com"
  s.files = FileList["lib/**/*", "[A-Z]*", "Rakefile", "docs/**/*"]
  s.homepage = "https://github.com/livingsocial/ankusa"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.5"
  s.add_dependency('hbaserb', '>= 0.0.3')
  s.add_dependency('fast-stemmer', '>= 1.0.0')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Default task: builds gem and runs tests"
task :default => [ :gem, :test ]
