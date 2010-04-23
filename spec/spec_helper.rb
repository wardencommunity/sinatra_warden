Bundler.require(:default, :runtime, :test)
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['RACK_ENV'] ||= 'test'

require 'sinatra_warden'
require 'spec'
require 'spec/autorun'

DataMapper.setup(:default, 'sqlite3::memory:')

%w(fixtures support).each do |path|
  Dir[ File.join(File.dirname(__FILE__), path, '/**/*.rb') ].each do |m|
    require m
  end
end

Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)

  config.before(:each) do
    DataMapper.auto_migrate!
  end

  def app
    @app ||= Rack::Builder.app do
      use Rack::Session::Cookie
      use Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = TestingLogin
        manager.serialize_into_session { |user| user.id }
        manager.serialize_from_session { |id| User.get(id) }
      end
      use Rack::Flash
      run TestingLogin
    end
  end
end

