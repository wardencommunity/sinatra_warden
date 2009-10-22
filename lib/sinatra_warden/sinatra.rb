module SinatraWarden
  module Helpers
    # The main accessor for the warden proxy instance
    def warden
      request.env['warden']
    end

    # Proxy to the authenticated? method on warden
    def authenticated?(*args)
      warden.authenticated?(*args)
    end
    alias_method :logged_in?, :authenticated?

    # Access the currently logged in user
    def user(*args)
      warden.user(*args)
    end
    alias_method :current_user, :user

    # Set the currently logged in user
    def user=(user)
      warden.set_user user
    end
    alias_method :current_user=, :user=

    # Require authorization for an action
    def authorize!(failure_path=nil)
      redirect_to(failure_path ? failure_path : '/') unless authenticated?
    end
  end

  def self.registered(app)
    app.helpers SinatraWarden::Helpers

    app.post '/unauthenticated/?' do
      status 401
      flash[:error] = "Could not log you in"
      haml :login
    end

    app.get '/login/?' do
      haml :login
    end

    app.post '/login/?' do
      env['warden'].authenticate!
      flash[:success] = "You have logged in successfully."
      redirect "/"
    end

    app.get '/logout/?' do
      env['warden'].logout
      flash[:success] = "You are now logged out."
      redirect '/'
    end
  end
end
