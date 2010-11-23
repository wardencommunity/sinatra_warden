require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Sinatra::Warden" do

  before(:each) do
    @user = User.create(:email => 'justin.smestad@gmail.com', :password => 'thedude')
  end

  it "should be a valid user" do
    @user.new?.should be_false
  end

  it "should create successfully" do
    @user.password.should == "thedude"
    User.authenticate('justin.smestad@gmail.com', 'thedude').should == @user
  end

  context "the authentication system" do
    it "should allow us to login as that user" do
      post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
      last_request.env['warden'].authenticated?.should == true
    end

    it "should allow us to logout after logging in" do
      post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
      last_request.env['warden'].authenticated?.should == true
      get '/logout'
      last_request.env['warden'].authenticated?.should == false
    end
    
    context "auth_use_referrer is disabled" do
      it "should not store :return_to" do
        get '/dashboard'
        follow_redirect!
        last_request.session[:return_to].should be_nil
      end
    
      it "should redirect to a default success URL" do
        get '/dashboard'
        follow_redirect!
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        follow_redirect!
        last_request.path.should == '/welcome'
      end
    end
    
    context "when auth_use_referrer is set to true" do
      def app; app_with_referrer; end
      
      it "should store referrer in user's session" do
        get '/dashboard'
        follow_redirect!
        last_request.session[:return_to].should == "/dashboard"
      end
      
      it "should redirect to stored return_to URL" do
        get '/dashboard'
        follow_redirect!
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        follow_redirect!
        last_request.path.should == '/dashboard'
      end
      
      it "should remove :return_to from session" do
        get '/dashboard'
        follow_redirect!
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        follow_redirect!
        last_request.session[:return_to].should be_nil
      end
      
      it "should default to :auth_success_path if there wasn't a return_to" do
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        follow_redirect!
        last_request.path.should == '/welcome'
      end
    end
    
    context "TestingLoginAsRackApp" do
      def app; @app ||= TestingLoginAsRackApp; end
      
      # what happens here is you'll eventually get
      # "stack too deep" error if the following test fails
      it "should not get in a loop" do
        post '/login', :email => 'bad', :password => 'password'
        last_request.path.should == '/unauthenticated'
      end
    end
  end

  context "the helpers" do

    context "the authorize! helper" do
      it "should redirect to root (default) if not logged in" do
        get '/admin'
        follow_redirect!
        last_request.url.should == 'http://example.org/'
      end

      it "should redirect to the passed path if available" do
        get '/dashboard'
        follow_redirect!
        last_request.url.should == 'http://example.org/login'
      end

      it "should allow access if user is logged in" do
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        last_request.env['warden'].authenticated?.should be_true
        get '/dashboard'
        last_response.body.should == "My Dashboard"
      end
    end

    context "the user helper" do

      before(:each) do
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        last_request.env['warden'].authenticated?.should be_true
      end

      it "should be aliased to current_user" do
        get '/admin'
        last_response.body.should == "Welcome #{@user.email}"
      end

      it "should allow assignment of the user (user=)" do
        john = User.create(:email => 'john.doe@hotmail.com', :password => 'secret')
        last_request.env['warden'].user.should == @user
        post '/login_as', 'email' => 'john.doe@hotmail.com', 'password' => 'secret'
        last_request.env['warden'].user.should == john
      end

      it "should return the current logged in user" do
        get '/account'
        last_response.body.should == "#{@user.email}'s account page"
      end

    end

    context "the logged_in/authenticated? helper" do

      before(:each) do
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        last_request.env['warden'].authenticated?.should be_true
      end

      it "should be aliased as logged_in?" do
        get '/check_login'
        last_response.body.should == "Hello Moto"
      end

      it "should return false when a user is not authenticated" do
        get '/logout'
        last_request.env['warden'].authenticated?.should be_false

        get '/check_login'
        last_response.body.should == "Get out!"
      end

    end

    context "the warden helper" do

      before(:each) do
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        last_request.env['warden'].authenticated?.should be_true
      end

      it "returns the environment variables from warden" do
        get '/warden'
        last_response.body.should_not be_nil
      end

    end
  end

  context "Rack::Flash integration" do

    it "should return a success message when logging in" do
      post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
      last_request.env['x-rack.flash'][:success].should == "You have logged in successfully."
    end

    it "should return a success message when logging out" do
      post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
      get  '/logout'
      last_request.env['x-rack.flash'][:success].should == "You have logged out successfully."
    end

    it "should return an error message" do
      post '/login', 'email' => 'bad', 'password' => 'wrong'
      last_request.env['x-rack.flash'][:error].should == "Could not log you in."
    end

  end

  context "OAuth support" do
    context "when enabled" do
      before do
        pending
        #TestingLogin.set(:auth_use_oauth, true)
        #@app = app
      end

      it "should redirect to authorize_url" do
        get '/login'
        follow_redirect!
        last_request.url.should == "http://twitter.com/oauth/authorize"
      end

      it "should redirect to a custom authorize_url, if set" do
        get '/login'
        follow_redirect!
        last_request.url.should == "http://facebook.com"
      end

    end
  end

end
