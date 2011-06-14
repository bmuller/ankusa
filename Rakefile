require 'rubygems'
require 'bundler'
require 'rake/testtask'
require 'rdoc/task'

Bundler::GemHelper.install_tasks

desc "Create documentation"
RDoc::Task.new("doc") { |rdoc|
  rdoc.title = "Ankusa - Naive Bayes classifier with big data storage"
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
  t.test_files = FileList['test/hasher_test.rb']
  t.verbose = true
}

desc "Run all unit tests with Cassandra storage"
Rake::TestTask.new("test_cassandra") { |t|
  t.libs << "lib"
  t.test_files = FileList['test/hasher_test.rb', 'test/cassandra_classifier_test.rb']
  t.verbose = true
}

desc "Run all unit tests with FileSystem storage"
Rake::TestTask.new("test_filesystem") { |t|
  t.libs << "lib"
  t.test_files = FileList['test/hasher_test.rb', 'test/file_system_classifier_test.rb']
  t.verbose = true
}
