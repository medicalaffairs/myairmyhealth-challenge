require 'spec_helper'

describe "Users" do

  describe "signup" do

    before(:each) do
      @user = FactoryGirl.build(:user) 
    end

    describe "success" do
      it "should register user" do
        lambda do
          visit new_user_registration_path 
          fill_in "First name", :with => @user.firstname
          fill_in "E-mail", :with => @user.email
          fill_in "Password", :with => @user.password
          fill_in "Confirm password", :with => @user.password_confirmation
          click_button "Sign up"
          save_page
          page.should have_content("A message with a confirmation link has been sent to your email address.")
          page.should have_selector("title", :content => "Home")
          current_path.should == root_path
        end.should change(User, :count).by(1)
      end

      it "allows users to sign in after they have registered" do
        @user.confirm!
        visit user_session_path
        fill_in "E-mail", :with => @user.email
        fill_in "Password", :with => @user.password
        click_button "Sign in"
        page.should have_content("Signed in successfully.")
      end

    end

    describe "failure" do
      it "should fail registration with bad password confirmation" do
        lambda do
          visit new_user_registration_path 
          fill_in "First name", :with => @user.firstname
          fill_in "E-mail", :with => @user.email
          fill_in "Password", :with => @user.password
          fill_in "Confirm password", :with => ""
          click_button "Sign up"
          page.should have_content("Password doesn't match confirmation")
        end.should_not change(User, :count)
      end
      
      it "fail to sign in after registration with bad password" do
        @user.confirm!
        visit user_session_path
        fill_in "E-mail", :with => @user.email
        fill_in "Password", :with => ""
        click_button "Sign in"
        page.should have_content("Invalid email or password.")
      end
    end

  end
end
