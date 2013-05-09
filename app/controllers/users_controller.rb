#class UsersController < Devise::SessionsController 
class UsersController < ApplicationController

  before_filter :authenticate_user!

  def new
  	@title = "Sign up"
  end

  def show
  	@title = "Profile"

  	if (params.has_key?(:id))
      if (params[:id].to_i != current_user.id.to_i)
        flash[:error] = 'Access denied'
        redirect_to :user_unauthorized
      else
        @user = User.find(params[:id])
	  	end
    else
	  	@user = User.find(current_user)
	  end
	 
  end

  def unauthorized
    @title = "Access Denied"
  	@user = User.find(current_user)
  end
 
end
