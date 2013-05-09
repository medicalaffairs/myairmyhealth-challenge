class MapController < ApplicationController

  before_filter :authenticate_user!

	def markers
    @user = User.find(current_user)
    @sample = []

    location_device_options  = JSON.parse(params['location_menu_options']) || nil
    time_options  = JSON.parse(params['time_menu_options']) || nil
    
    if time_options then
      options = {:time_opts => { :start_date => time_options['start_date'], :end_date => time_options['end_date'] }}
    end

    location_device_options.each do |v|
      if v['selected'] == true
        device_to_sample = Device.where("id = ? and user_id = ?", v['device_id'], current_user.id).all

        unless device_to_sample.nil?
          device_to_sample.each do |d|
            @sample.concat( d.locations( options ))
          end
        end
      end
    end
    @sample.sort{|x,y| y.date <=> x.date }
    @polyline = DataGPS.to_polyline ( {:data => @sample} )
    
    respond_to do |format|
    #format.js 
    format.json { render :json => sample.to_gmaps4rails }
    format.html { render :text =>  sample.to_gmaps4rails }
    return
    end    
  end
end
