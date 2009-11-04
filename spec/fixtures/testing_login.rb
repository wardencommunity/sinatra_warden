class TestingLogin < Sinatra::Base
  register Sinatra::Warden

  set :views, File.join(File.dirname(__FILE__), 'views')
  set :sessions, true

  set :auth_success_path, '/welcome'

  get '/dashboard' do
    authorize!('/login')
    "My Dashboard"
  end

  get '/account' do
    authorize!
    "#{user.email}'s account page"
  end

  post '/login_as/?' do
    authorize!
    user = User.authenticate(params['email'], params['password'])
  end

  get '/admin' do
    authorize!
    "Welcome #{current_user.email}"
  end

end
