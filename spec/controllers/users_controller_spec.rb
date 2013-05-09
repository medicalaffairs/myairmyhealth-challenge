require 'spec_helper'

describe UsersController do
  render_views
  
  describe "visit new_user_registration_path" do
    before(:each) do
      visit new_user_registration_path 
    end
    
    it "returns http success" do
      expect(current_path).to eq(new_user_registration_path)
    end

    it "should have the right title" do
      page.should have_selector("h2", :content => "Sign up")
    end

    it "should have a first name field" do
      page.should have_selector("input[name='user[firstname]'][type='text']")
    end
    it "should have a last name field" do
      page.should have_selector("input[name='user[lastname]'][type='text']")
    end
    it "should have a email field" do
      page.should have_selector("input[name='user[email]'][type='email']")
    end
    it "should have a password field" do
      page.should have_selector("input[name='user[password]'][type='password']")
    end
    it "should have a password confirmation field" do
      page.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end

  end

  describe "GET 'show'" do

    before(:each) do
      @user = FactoryGirl.create(:confirmed_user)  #or build?
      @user2 = FactoryGirl.create(:confirmed_user, :firstname => "Laura", :email => "second@philips.com")  #or build?
      sign_in @user2
    end

    it "should not be successful" do
      get :show, :id=> @user
      response.should redirect_to(:user_unauthorized)
    end
  end
  
  describe "GET 'show'" do

     before(:each) do
       @user = FactoryGirl.create(:confirmed_user)  #or build?
       sign_in @user
     end

    it "should be successful" do
      get :show  
      response.should have_selector("title",:content => 'Profile')
    end

    it "should find the right user" do
      visit user_profile_path #, :id => @user
      get :show, :id => @user 
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title",:content => "Profile")
    end

    it "should include the users's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.firstname+' '+@user.lastname)
    end

    it "should have a profile image" do 
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
  end

end
