# == Schema Information
#
# Table name: devices
#
#  id                      :integer          not null, primary key
#  devicename              :string(255)
#  user_id                 :integer
#  device_authorization_id :integer
#  is_authorized           :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  type                    :string(255)
#

class DeviceBtraced < Device
  # attr_accessible :title, :body


  def locations(params={})
    locs=DataBtraced.where(:user_id => self.user.id).all 
    #, "date.gt" => params[:time_opts][:start_time].to_i).all
    #locs=DataBtraced.search_by_date( {:user_id => self.user.id, :start_time => params[:time_opts][:start_time] })
    locs.each do |x|
      x.date = x.date-14400
    end
    if params[:time_opts] then
      locs=locs.select { |x| x.date >= params[:time_opts][:start_date].to_i }.select { |x| x.date <= params[:time_opts][:end_date].to_i}
    end
    locs.sort{|x,y| y.date <=> x.date }
  end

  def info
    data = super
    unless self.device_authorization.nil? 
      a = DataBtraced.create(:id => "create_table", :user_id => 0).save.delete
      data.merge!(btraced_info)
    end
    return data
  end
   
  def add_data(datahash)

    saved_points = Array.new

    datahash[:bwiredtravel][:travel][:point].each do |pt|
      utc_epoch = pt[:date].to_i-datahash[:bwiredtravel][:timeOffset].to_i
      datestr = Time.at(utc_epoch).strftime "%Y/%m/%d - %H:%M:%S"

      user_id_checkin_id =  self.user.id.to_s + "_" + utc_epoch.to_s

      f =  DataBtraced.find_by_id(user_id_checkin_id)
      if f.nil? then
        u = DataBtraced.new( :id => user_id_checkin_id, 
                            :date => utc_epoch.to_i,
                            :timeZoneOffset => datahash[:bwiredtravel][:timeOffset], 
                            :latitude => pt[:lat], 
                            :longitude => pt[:lon], 
                            :location => "".to_json, 
                            :user_id => self.user.id)
        if u.save 
          saved_points.push pt[:id].to_i
        else
          raise("Error saving to DynamoDB")
        end
      end
      
    end

    answer ={}
    answer[:id]=0;
    answer[:tripid]=datahash["bwiredtravel"]["travel"]["id"].to_i
    if saved_points.nil? then
      answer[:error]=true
      answer[:message]="Please try again later. MyAirMyHealth reported an error processing your data."
    else
      answer[:points]=saved_points
    end
    answer[:valid]=true
    if datahash[:bwiredtravel][:travel][:getTripUrl] then
      answer[:tripURL]="https%3a%2f%2fmyairmyhealth.medicalaffairs.philips.com"
    end
  	return answer.to_json
  end
  
  def btraced_info
    btraced_user_info #.merge(btraced_location_info)
  end
  
  def foursquare_location_info
    locations =  FoursquareData.where(:user_id => self.user.id).all
    h={}
    locations.each do |locdata|
      data=Array.new
      data.push locdata.to_latlong_s
      data.push locdata.to_address_s
      h[locdata.to_time_s] = data.join(". ")
    end
    {"Checkins" => Hash[h.sort]}
  end
  
  def btraced_user_info
    hash={}
    hash["Callback URL"] = "http://"+::Rails.application.config.action_mailer.default_url_options[:host]+"/gps/"+self.device_authorization.uid
    {"User Info" => hash}
  end

  def is_location_device?
    true
  end
end
