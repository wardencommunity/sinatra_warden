class TestingLogin < Sinatra::Base
  register Sinatra::Warden

  get '/dashboard' do
    authorize!('/login')
  end

  get '/admin' do
    authorize!
  end

end
