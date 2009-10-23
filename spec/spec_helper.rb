$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['RACK_ENV'] ||= 'test'
project_root = File.expand_path(File.dirname(__FILE__))
require File.join(project_root, '..', 'vendor', 'gems', 'environment')
Bundler.require_env(:test)

require 'sinatra_warden'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|

end
