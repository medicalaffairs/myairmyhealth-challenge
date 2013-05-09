# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  firstname              :string(255)
#  lastname               :string(255)
#  birthday               :date
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#

require 'spec_helper'

describe User do

  before(:each) do
  	@attr = {:firstname => "example", :email => "user@philips.com",
  			 :password => "foobar12", :password_confirmation => "foobar12"}
  end

  it "should create a new instance given valid attributes" do
  	User.create!(@attr)
  end

  it "should require a first name" do
  	no_name_user  = User.new(@attr.merge(:firstname=>" "))
  	no_name_user.should_not be_valid
  end

  it "should require a first name no longer than 15 chars" do
  	long_name_user  = User.new(@attr.merge(:firstname=> ("a"*16)))
  	long_name_user.should_not be_valid
  end

  it "should require an email address" do
  	no_email_user  = User.new(@attr.merge(:email=>" "))
  	no_email_user.should_not be_valid
  end

  it "should accept valid email addresses" do
 	addresses = %w[user@philips.com THE_USER@philips.com first.last@philips.com]
 	addresses.each do |address|
 		valid_email_user = User.new(@attr.merge(:email => address))
  		valid_email_user.should be_valid
  	end
  end

  it "should reject invalid email addresses" do
 	addresses = %w[user@foo,com test @test. g@g. user@ @com what@who] 
 	addresses.each do |address|
 		invalid_email_user = User.new(@attr.merge(:email => address))
  		invalid_email_user.should_not be_valid
  	end
  end

  it "should reject duplicate email addresses" do
 	User.create!(@attr)
 	user_with_duplicate_email = User.new(@attr)
  	user_with_duplicate_email.should_not be_valid
  end

  it "should reject duplicate email addresses up to case" do
 	User.create!(@attr)
 	user_with_duplicate_email = User.new(@attr.merge(:email => @attr[:email].upcase))
  	user_with_duplicate_email.should_not be_valid
  end

  describe "password validations" do

  	it "should require a password" do
  		User.new(@attr.merge(:password => "", :password_confirmation => "")).
  		should_not be_valid
  	end

  	it "should require a matching password validation" do
  		User.new(@attr.merge(:password_confirmation => "notfoobar")).
  		should_not be_valid
  	end

  	it "should reject short passwords" do 
  		short_password ="a"*5;
  		hash = @attr.merge(:password => short_password, :password_confirmation => short_password)
  		User.new(hash).should_not be_valid
  	end

  	it "should reject long passwords" do 
  		long_password ="a"*129;
  		hash = @attr.merge(:password => long_password, :password_confirmation => long_password)
  		User.new(hash).should_not be_valid
  	end
  	    
	end

end
