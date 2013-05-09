require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Home page at '/'" do
  	get '/'
  	response.should have_selector('title', :content => "Home")
  end

  it "should have a Contact page at '/contact'" do
  	get '/contact'
  	response.should have_selector('title', :content => "Contact")
  end

  it "should have a About page at '/about'" do
  	get '/about'
  	response.should have_selector('title', :content => "About")
  end

  it "should have a Help page at '/help'" do
  	get '/help'
  	response.should have_selector('title', :content => "Help")
  end

  before(:each) do
    visit root_path
  end
  
  it "should have a functional About link" do
    click_link "About"
    page.should have_selector('title', :content => "About")
  end
  
  it "should have a functional Contact link" do
    click_link "Contact"
    page.should have_selector('title', :content => "Contact")
  end
  
  it "should have a functional Help link" do   
    click_link "Help"
    page.should have_selector('title', :content => "Help")
  end
  
  it "should have a functional Home link" do
    click_link "Home"
    page.should have_selector('title', :content => "Home")
  end
  
  it "should have a functional Sign in link" do
    click_link "signinlink"
    page.should have_selector('title', :content => "Sign in")
  end
  
  it "should have a functional Sign in button" do
    find("#signinbutton").click
    page.should have_selector('title', :content => "Sign in")
  end
  
  it "should have a functional Sign up button" do
    click_link "Sign up now!"
    page.should have_selector('h2', :content => "Sign up")
  end
  
end