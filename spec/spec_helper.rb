$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['RACK_ENV'] ||= 'test'

require 'sinatra_warden'
require 'rspec'
require 'rspec/autorun'
require 'dm-core'
require 'dm-migrations'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

DataMapper.setup(:default, 'sqlite3::memory:')

%w(fixtures support).each do |path|
  Dir[ File.join(File.dirname(__FILE__), path, '/**/*.rb') ].each do |m|
    require m
  end
end

RSpec.configure do |config|
  config.include(Rack::Test::Methods)

  config.before(:each) do
    DataMapper.auto_migrate!
  end

  # default app
  def app
    @app ||= define_app TestingLogin
  end

  # app with auth_use_referrer enabled
  def app_with_referrer
    @app ||= define_app TestingLoginWithReferrer
  end

private

  # :which should be a sinatra app
  def define_app(which)
    Rack::Builder.new do
      use Rack::Session::Cookie
      use Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = which
        manager.serialize_into_session { |user| user.id }
        manager.serialize_from_session { |id| User.get(id) }
      end
      use Rack::Flash
      run which
    end
  end
end

