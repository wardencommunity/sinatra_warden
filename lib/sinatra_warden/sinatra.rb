require 'sinatra/base'
require 'warden'

module Sinatra
  module Warden
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
        redirect(failure_path ? failure_path : '/') unless authenticated?
      end
    end

    def self.registered(app)
      app.helpers Warden::Helpers

      app.post '/unauthenticated/?' do
        status 401
        flash[:error] = "Could not log you in" if defined?(Rack::Flash)
        haml :login
      end

      app.get '/login/?' do
        haml :login
      end

      app.post '/login/?' do
        env['warden'].authenticate!
        flash[:success] = "You have logged in successfully." if defined?(Rack::Flash)
        redirect back
      end

      app.get '/logout/?' do
        env['warden'].logout
        flash[:success] = "You are now logged out." if defined?(Rack::Flash)
        redirect back
      end
    end
  end # Warden

  register Warden
end # Sinatra
