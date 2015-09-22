require 'sinatra/base'
module Sinatra
  module Warden
    module Helpers

      # The main accessor to the warden middleware
      def warden
        request.env['warden']
      end

      # Return session info
      #
      # @param [Symbol] the scope to retrieve session info for
      def session_info(scope=nil)
        scope ? warden.session(scope) : scope
      end

      # Check the current session is authenticated to a given scope
      def authenticated?(scope=nil)
        scope ? warden.authenticated?(:scope => scope) : warden.authenticated?
      end
      alias_method :logged_in?, :authenticated?

      # Authenticate a user against defined strategies
      def authenticate(*args)
        warden.authenticate!(*args)
      end
      alias_method :login, :authenticate

      # Terminate the current session
      #
      # @param [Symbol] the session scope to terminate
      def logout(scopes=nil)
        scopes ? warden.logout(scopes) : warden.logout(warden.config.default_scope)
      end

      # Access the user from the current session
      #
      # @param [Symbol] the scope for the logged in user
      def user(scope=nil)
        scope ? warden.user(scope) : warden.user
      end
      alias_method :current_user, :user

      # Store the logged in user in the session
      #
      # @param [Object] the user you want to store in the session
      # @option opts [Symbol] :scope The scope to assign the user
      # @example Set John as the current user
      #   user = User.find_by_name('John')
      def user=(new_user, opts={})
        warden.set_user(new_user, opts)
      end
      alias_method :current_user=, :user=

      # Require authorization for an action
      #
      # @param [String] path to redirect to if user is unauthenticated
      def authorize!(failure_path=nil)
        unless authenticated?
          session[:return_to] = request.path if settings.auth_use_referrer
          redirect(failure_path ? failure_path : settings.auth_failure_path)
        end
      end

    end

    def self.registered(app)
      app.helpers Warden::Helpers

      # Enable Sessions
      unless defined?(Rack::Session::Cookie)
        app.set :sessions, true
      end

      app.set :auth_failure_path, '/'
      app.set :auth_success_path, '/'
      # Setting this to true will store last request URL
      # into a user's session so that to redirect back to it
      # upon successful authentication
      app.set :auth_use_referrer, false

      app.set :auth_error_message,   "Could not log you in."
      app.set :auth_success_message, "You have logged in successfully."
      app.set :auth_template_renderer, :haml
      app.set :auth_login_template, :login

      # OAuth Specific Settings
      app.set :auth_use_oauth, false

      app.post '/unauthenticated/?' do
        status 401
        warden.custom_failure! if warden.config.failure_app == self.class
        env['x-rack.flash'][:error] = settings.auth_error_message if defined?(Rack::Flash)
        self.send(settings.auth_template_renderer, settings.auth_login_template)
      end

      app.get '/login/?' do
        if settings.auth_use_oauth && !@auth_oauth_request_token.nil?
          session[:request_token] = @auth_oauth_request_token.token
          session[:request_token_secret] = @auth_oauth_request_token.secret
          redirect @auth_oauth_request_token.authorize_url
        else
          self.send(settings.auth_template_renderer, settings.auth_login_template)
        end
      end

      app.get '/oauth_callback/?' do
        if settings.auth_use_oauth
          authenticate
          env['x-rack.flash'][:success] = settings.auth_success_message if defined?(Rack::Flash)
          redirect settings.auth_success_path
        else
          redirect settings.auth_failure_path
        end
      end

      app.post '/login/?' do
        authenticate
        env['x-rack.flash'][:success] = settings.auth_success_message if defined?(Rack::Flash)
        redirect settings.auth_use_referrer && session[:return_to] ? session.delete(:return_to) : settings.auth_success_path
      end

      app.get '/logout/?' do
        authorize!
        logout
        env['x-rack.flash'][:success] = settings.auth_success_message if defined?(Rack::Flash)
        redirect settings.auth_success_path
      end
    end
  end # Warden

  register Warden
end # Sinatra
