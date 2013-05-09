class SinglyController < ApplicationController
  def new
  end

  def create
    auth_hash = request.env['omniauth.auth']
    if DeviceAuthorization.create_or_update_from_hash(auth_hash, current_user)
      redirect_to user_profile_url and return
    else
      redirect_to :failure
    end
   end

  def failure
    render :text => "Sorry, but you didn't allow access to our app!"
  end
  
end
