class TestingLogin < Sinatra::Base
  register Sinatra::Warden

  set :views, File.join(File.dirname(__FILE__), 'views')
  set :sessions, true

  set :auth_success_path, '/welcome'

  get '/dashboard' do
    authorize!('/login')
    "My Dashboard"
  end

  get '/admin' do
    authorize!
  end

end
