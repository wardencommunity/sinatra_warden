require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SinatraWarden" do
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
        last_request.env['warden'].authenticated?.should == true
        get '/dashboard'
        last_response.body.should == "My Dashboard"
      end

    end

    context "the user helper" do

      it "should be aliased to current_user"

      it "should allow assignment of the user (user=)"

      it "should return the current logged in user"

    end

    context "the authenticated? helper" do

      it "should be aliased as logged_in?"

      it "should return true when a user is authenticated"

      it "should return false when a user is not authenticated"

    end

    context "the warden helper" do

      it "returns the environment variables from warden"

    end
  end

end
