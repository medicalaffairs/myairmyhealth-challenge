class DevicesController < ApplicationController

  before_filter :authenticate_user!

  def new
   	@title = "Connect a New Device"
   	@device = User.find(current_user).devices.new
  end
   
  def index
    @title = "All Devices"
    @user = User.find(current_user)
  end
  
  def show  
  	@title = "Device Details"
    begin  
      @device = User.find(current_user).devices.find(params[:id])
      @last_n = 20
      if @device.is_location_device? then
        sample = @device.locations.take(@last_n)
        @location_json = sample.to_gmaps4rails
        @polyline_json = DataGPS.to_polyline ( {:data => sample} )
      end
    rescue 
      redirect_to :action => :index 
    end
  end

  def create

    case (params[:devicename])
    when "BodyMedia"
      provider =  :bodymedia
      service =   :bodymedia  
      device_class = "DeviceBodymedia"
    when "Withings"
      provider =  :singly
      service = :withings
      device_class = "DeviceWithings"
    when "Foursquare (GPS)"
      provider =  :foursquare
      service = :foursquare
      device_class = "DeviceFoursquare"
    when "Cosm Feed"
      provider =  :cosm
      service = :cosm
      device_class = "DeviceCosm"
    when "Twitter"
      provider =  :singly
      service = :twitter
      device_class = "Device"
    when "Facebook"
      provider =  :singly
      service = :facebook
      device_class = "Device"
    when "LinkedIn"
      provider =  :singly
      service = :linkedin
      device_class = "Device"
    when "Btraced (GPS)"
      provider = :btraced
      service = :btraced
      device_class = "DeviceBtraced"
    when "NanoTracer"
      provider = :nanotracer
      service = :nanotracer
      device_class = "DeviceNanotracer"
    when "Respiratory Flow Meter"
      provider = :respiratory
      service = :respiratory
      device_class = "DeviceRespiratory"
    else
      provider = nil
      service = nil
      device_class = "Device"
    end
    
    if provider == :singly 
      if User.find(current_user).devices.create( :devicename => params[:devicename], :is_authorized => false, :type => device_class )
        auth_token = DeviceAuthorization.get_auth_token(:provider => provider, :user => current_user);
        url= "/auth/singly?service=" + service.to_s + (auth_token.empty? ? "" : "&access_token=" + auth_token.first )
        redirect_to url and return
      end
    elsif provider == :foursquare
      if d=User.find(current_user).devices.create( :devicename => params[:devicename], :is_authorized => false, :type => device_class )
        redirect_to foursquare_authorize_path and return
      end
    elsif provider == :cosm
      if d=User.find(current_user).devices.create( :devicename => params[:devicename], :is_authorized => false, :type => device_class )
        redirect_to cosm_select_feed_path and return
      end
    elsif provider == :bodymedia
      if d=User.find(current_user).devices.create( :devicename => params[:devicename], :is_authorized => false, :type => device_class )
        redirect_to bodymedia_authorize_path and return
      end
    elsif provider == :btraced
      if d=User.find(current_user).devices.create( :devicename => params[:devicename], :is_authorized => false, :type => device_class )
        redirect_to btraced_authorize_path and return
      end
    elsif provider == :nanotracer
      if d=User.find(current_user).devices.create( :devicename => params[:devicename], :is_authorized => false, :type => device_class )
        redirect_to nanoreporter_authorize_path and return
      end
    elsif provider == :respiratory
      if d=User.find(current_user).devices.create( :devicename => params[:devicename], :is_authorized => false, :type => device_class )
        redirect_to respiratory_authorize_path and return
      end
    else
      if User.find(current_user).devices.create( :devicename => params[:devicename], :is_authorized => true, :type => device_class )
        redirect_to user_profile_path and return
      end      
    end
    
    render :failure and return

  end
  
  def complete_create
    
  end
  
  def destroy
    device = Device.find(params[:id])
    unless device[:device_authorization_id].nil?
      unless  DeviceAuthorization.find(device[:device_authorization_id]).provider == :singly 
        DeviceAuthorization.find(device[:device_authorization_id]).delete
      end
    end
    Device.find(params[:id]).destroy    
    redirect_to user_profile_path
  end
  
  def failure
    
  end
  
end
