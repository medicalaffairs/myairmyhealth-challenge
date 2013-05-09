require 'Factory_Girl'
#By using the symbol ':user' we get Factory Girl to simulate the User model

FactoryGirl.define do
  
  factory :user do 
	  firstname				"Guy"
	  lastname				"Shechter"
	  email					"user@philips.com"
	  password 				"foobar123"
	  password_confirmation	"foobar123"
	end
	
	factory :confirmed_user, :parent => :user do
      after(:create) { |user| user.confirm! }
  end
  
end