require 'rubygems'
require 'test/unit'
require 'yaml'

$:.unshift(File.join File.dirname(__FILE__), '..', 'lib')
require 'ankusa'

CONFIG = YAML.load_file File.join(File.dirname(__FILE__), "config.yml")
