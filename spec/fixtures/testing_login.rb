class TestingLogin < Sinatra::Base
  register SinatraWarden

  get '/dashboard' do
    authorize!('/login')
  end

  get '/admin' do
    authorize!
  end

end
