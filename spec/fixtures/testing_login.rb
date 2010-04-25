Warden::Strategies.add(:password) do
  def valid?
    # params['email'] && params['password']
    # p params
    true
  end

  def authenticate!
    u = User.authenticate(params['email'], params['password'])
    u.nil? ? fail!("Could not log you in.") : success!(u)
  end
end

class TestingLogin < Sinatra::Base
  register Sinatra::Warden

  set :views, File.join(File.dirname(__FILE__), 'views')
  set :sessions, true

  set :auth_success_path, '/welcome'

  get '/dashboard' do
    authorize!('/login')
    "My Dashboard"
  end

  get '/warden' do
    authorize!
    "#{warden}"
  end

  get '/check_login' do
    logged_in? ? "Hello Moto" : "Get out!"
  end

  get '/account' do
    authorize!
    "#{user.email}'s account page"
  end

  post '/login_as' do
    authorize!
    self.user = User.authenticate(params['email'], params['password'])
  end

  get '/admin' do
    authorize!
    "Welcome #{current_user.email}"
  end

end

class TestingLoginWithReferrer < TestingLogin
  set :auth_use_referrer, true
end

class TestingLoginAsRackApp < TestingLogin
  use Rack::Session::Cookie
  use Warden::Manager do |manager|
    manager.default_strategies :password
    manager.failure_app = TestingLoginAsRackApp
    manager.serialize_into_session { |user| user.id }
    manager.serialize_from_session { |id| User.get(id) }
  end
  use Rack::Flash
  
  set :auth_failure_path, '/login'
end
