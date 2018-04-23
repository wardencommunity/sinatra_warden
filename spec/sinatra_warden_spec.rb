require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe "Sinatra::Warden" do
  include Warden::Test::Helpers

  before(:each) do
    @user = User.create(:email => 'justin.smestad@gmail.com', :password => 'thedude')
  end

  after{ Warden.test_reset! }

  def registered_user
    User.first(:email => 'justin.smestad@gmail.com')
  end

  it "should be a valid user" do
    expect(@user.new?).to be_falsey
  end

  it "should create successfully" do
    expect(@user.password).to eq("thedude")
    expect(User.authenticate('justin.smestad@gmail.com', 'thedude')).to eq(@user)
  end

  context "the authentication system" do
    it "should allow us to login as that user" do
      post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
      expect(last_request.env['warden'].authenticated?).to eq(true)
    end

    it "should allow us to logout after logging in" do
      post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
      expect(last_request.env['warden'].authenticated?).to eq(true)
      get '/logout'
      expect(last_request.env['warden'].authenticated?).to eq(false)
    end

    context "auth_use_referrer is disabled" do
      it "should not store :return_to" do
        get '/dashboard'
        follow_redirect!
        expect(last_request.session[:return_to]).to be_nil
      end

      it "should redirect to a default success URL" do
        get '/dashboard'
        follow_redirect!
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        follow_redirect!
        expect(last_request.path).to eq('/welcome')
      end
    end

    context "when auth_use_referrer is set to true" do
      def app; app_with_referrer; end

      it "should store referrer in user's session" do
        get '/dashboard'
        expect(last_request.session[:return_to]).to eq("/dashboard")
      end

      it "should redirect to stored return_to URL" do
        get '/dashboard'
        expect(last_request.session[:return_to]).to eq('/dashboard')
        login_as registered_user
        expect(last_request.path).to eq('/dashboard')
      end

      it "should remove :return_to from session" do
        get '/dashboard'
        follow_redirect!
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        follow_redirect!
        expect(last_request.session[:return_to]).to be_nil
      end

      it "should default to :auth_success_path if there wasn't a return_to" do
        post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
        follow_redirect!
        expect(last_request.path).to eq('/welcome')
      end
    end

    context "TestingLoginAsRackApp" do
      def app; @app ||= TestingLoginAsRackApp; end

      # what happens here is you'll eventually get
      # "stack too deep" error if the following test fails
      it "should not get in a loop" do
        post '/login', :email => 'bad', :password => 'password'
        expect(last_request.env['warden.options'][:action]).to eq('unauthenticated')
      end
    end
  end

  context "the helpers" do

    context "the authorize! helper" do
      it "should redirect to root (default) if not logged in" do
        get '/admin'
        follow_redirect!
        expect(last_request.url).to eq('http://example.org/')
      end

      it "should redirect to the passed path if available" do
        get '/dashboard'
        follow_redirect!
        expect(last_request.url).to eq('http://example.org/login')
      end

      it "should allow access if user is logged in" do
        login_as registered_user
        get '/dashboard'
        expect(last_response.body).to eq("My Dashboard")
      end
    end

    context "the user helper" do

      it "should be aliased to current_user" do
        login_as registered_user
        get '/admin'
        expect(last_response.body).to eq("Welcome #{@user.email}")
      end

      it "should allow assignment of the user (user=)" do
        login_as registered_user
        get '/dashboard'
        expect(last_request.env['warden'].user).to eq(@user)

        john = User.create(:email => 'john.doe@hotmail.com', :password => 'secret')
        login_as john
        get '/dashboard'
        expect(last_request.env['warden'].user).to eq(john)
      end

      it "should return the current logged in user" do
        login_as registered_user
        get '/account'
        expect(last_response.body).to eq("#{@user.email}'s account page")
      end

    end

    context "the logged_in/authenticated? helper" do

      it "should be aliased as logged_in?" do
        login_as registered_user
        get '/check_login'
        expect(last_response.body).to eq("Hello Moto")
      end

      it "should return false when a user is not authenticated" do
        login_as registered_user

        get '/logout'
        expect(last_request.env['warden'].authenticated?).to be_falsey

        get '/check_login'
        expect(last_response.body).to eq("Get out!")
      end

    end

    context "the warden helper" do

      it "returns the environment variables from warden" do
        get '/warden'
        expect(last_response.body).not_to be_nil
      end

    end
  end

  context "Rack::Flash integration" do

    it "should return a success message" do
      post '/login', 'email' => 'justin.smestad@gmail.com', 'password' => 'thedude'
      expect(last_request.env['x-rack.flash'][:success]).to eq("You have logged in successfully.")
    end

    it "should return an error message" do
      post '/login', 'email' => 'bad', 'password' => 'wrong'
      expect(last_request.env['x-rack.flash'][:error]).to eq("Could not log you in.")
    end

  end

  context "OAuth support" do
    context "when enabled" do
      before do
        #TestingLogin.set(:auth_use_oauth, true)
        #@app = app
      end

      xit "should redirect to authorize_url" do
        get '/login'
        follow_redirect!
        expect(last_request.url).to eq("http://twitter.com/oauth/authorize")
      end

      xit "should redirect to a custom authorize_url, if set" do
        get '/login'
        follow_redirect!
        expect(last_request.url).to eq("http://facebook.com")
      end

    end
  end

end
