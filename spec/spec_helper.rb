$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['RACK_ENV'] ||= 'test'
project_root = File.expand_path(File.dirname(__FILE__))
require File.join(project_root, '..', 'vendor', 'gems', 'environment')
Bundler.require_env(:testing)

require 'sinatra_warden'
require 'spec'
require 'spec/autorun'

DataMapper.setup(:default, 'sqlite3::memory:')

%w(fixtures support).each do |path|
  Dir[ File.join(project_root, path, '/**/*.rb') ].each do |m|
    require m
  end
end

Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)
  config.include(TestingLogin::Helpers)

  config.before(:each) do
    DataMapper.auto_migrate!
  end

  def app
    @app ||= Rack::Builder.app do
      use Rack::Session::Cookie
      use Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = TestingLogin
      end
      use Rack::Flash
      run TestingLogin
    end
  end
end

