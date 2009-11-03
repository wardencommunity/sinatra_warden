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
      # @params [User] the user you want to log in
      def user=(user)
        warden.set_user user
      end
      alias_method :current_user=, :user=

      # Require authorization for an action
      # @params [String] path to redirect to if user is unauthenticated
      def authorize!(failure_path=nil)
        redirect(failure_path ? failure_path : options.auth_failure_path) unless authenticated?
      end
    end

    def self.registered(app)
      app.helpers Warden::Helpers
      
      app.set :auth_failure_path, '/'
      app.set :auth_success_path, lambda{ back }

      app.set :auth_error_message, "Could not log you in."
      app.set :auth_success_message, "You have logged in successfully."
      app.set :auth_use_erb, false
      app.set :auth_login_template, :login

      app.post '/unauthenticated/?' do
        status 401
        flash[:error] = "Could not log you in." if defined?(Rack::Flash)
        options.auth_use_erb ? erb(options.auth_login_template) : haml(options.auth_login_template)
      end

      app.get '/login/?' do
         options.auth_use_erb ? erb(options.auth_login_template) : haml(options.auth_login_template)
      end

      app.post '/login/?' do
        env['warden'].authenticate!
        flash[:success] = options.auth_success_message if defined?(Rack::Flash)
        redirect options.auth_success_path
      end

      app.get '/logout/?' do
        env['warden'].logout
        flash[:success] = options.auth_error_message if defined?(Rack::Flash)
        redirect options.auth_success_path
      end
    end
  end # Warden

  register Warden
end # Sinatra
