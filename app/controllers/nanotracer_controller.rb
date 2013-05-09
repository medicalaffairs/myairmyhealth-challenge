class NanotracerController < ApplicationController

  before_filter :authenticate_user!, :except => [:add]

  def new
  end

  def create
    auth_hash ={
      'provider' => 'nanotracer', 
      'uid' => params[:serial_number], 
      'credentials' => {
        'token' => 0
      }
    }
    if DeviceAuthorization.create_or_update_from_hash(auth_hash, current_user)
      redirect_to user_profile_url and return
    else
      redirect_to :failure
    end
  end

  def add
    render :text => DeviceNanotracer.add_data( params )
  end

  def authorize
    
  end

  def upload
    DeviceNanotracer.add_data_from_file(params["device_nanotracer"]["nanotracer_data"])
    redirect_to :back
  end

end
