class BtracedController < ApplicationController

  before_filter :authenticate_user!, :except => [:add]

  def new
  end

  def create
    auth_hash ={
      'provider' => 'btraced', 
      'uid' => params[:token], 
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
    auth = DeviceAuthorization.find_by_uid( params[:id] )
    device = Device.find_by_device_authorization_id( auth )
    render :text => device.add_data( params )
  end

  def authorize
    @token = SecureRandom.hex(5);
  end


end
