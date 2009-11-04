class TestingLogin < Sinatra::Base
  register Sinatra::Warden

  set :views, File.join(File.dirname(__FILE__), 'views')

  get '/dashboard' do
    authorize!('/login')
  end

  get '/admin' do
    authorize!
  end

end
