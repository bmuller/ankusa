require 'rubygems'
require 'test/unit'
require 'yaml'
require 'hbaserb'

$:.unshift(File.join File.dirname(__FILE__), '..', 'lib')
require 'ankusa'
require 'ankusa/cassandra_storage'

CONFIG = YAML.load_file File.join(File.dirname(__FILE__), "config.yml")
