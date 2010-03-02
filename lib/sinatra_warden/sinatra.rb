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
      #   Usage: self.user = @user
      #
      # @param [User] the user you want to log in
      def user=(new_user)
        warden.set_user(new_user)
      end
      alias_method :current_user=, :user=

      # Require authorization for an action
      # @param [String] path to redirect to if user is unauthenticated
      def authorize!(failure_path=nil)
        redirect(failure_path ? failure_path : options.auth_failure_path) unless authenticated?
      end

    end

    def self.registered(app)
      app.helpers Warden::Helpers

      # Enable Sessions
      app.set :sessions, true

      app.set :auth_failure_path, '/'
      app.set :auth_success_path, '/'

      app.set :auth_error_message,   "Could not log you in."
      app.set :auth_success_message, "You have logged in successfully."
      app.set :auth_use_erb, false
      app.set :auth_login_template, :login
      
      # OAuth Specific Settings
      app.set :auth_use_oauth, false

      app.post '/unauthenticated/?' do
        status 401
        flash[:error] = (env['warden'].message || options.auth_error_message) if defined?(Rack::Flash)
        options.auth_use_erb ? erb(options.auth_login_template) : haml(options.auth_login_template)
      end

      app.get '/login/?' do
        if options.auth_use_oauth && !@auth_oauth_request_token.nil?
          session[:request_token] = @auth_oauth_request_token.token
          session[:request_token_secret] = @auth_oauth_request_token.secret
          redirect @auth_oauth_request_token.authorize_url
        else          
          options.auth_use_erb ? erb(options.auth_login_template) : haml(options.auth_login_template)
        end
      end

      app.get '/oauth_callback/?' do
        if options.auth_use_oauth
          env['warden'].authenticate!
          flash[:success] = options.auth_success_message if defined?(Rack::Flash)
          redirect options.auth_success_path
        else
          redirect options.auth_failure_path
        end
      end

      app.post '/login/?' do
        env['warden'].authenticate!
        flash[:success] = options.auth_success_message if defined?(Rack::Flash)
        redirect options.auth_success_path
      end

      app.get '/logout/?' do
        authorize!
        env['warden'].logout(:default)
        flash[:success] = options.auth_success_message if defined?(Rack::Flash)
        redirect options.auth_success_path
      end
    end
  end # Warden

  register Warden
end # Sinatra
