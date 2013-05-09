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

class DeviceFoursquare < Device
  
  def locations(params={})
    locs=DataFoursquare.where(:user_id => self.user.id).all
    if params[:time_opts] then
      locs=locs.select { |x|  x.date >= params[:time_opts][:start_date].to_i }.select { |x| x.date <= params[:time_opts][:end_date].to_i}
    end
    locs.sort{|x,y| y.date <=> x.date }
  end

  def info
    data = super
    unless self.device_authorization.nil? 
      cache_data
      data.merge!(foursquare_info)
    end
    return data
  end
   
  def cache_data
    client = Foursquare2::Client.new(:oauth_token => self.device_authorization.auth_token)
    data = client.user_checkins

    a = DataFoursquare.create(:id => "create_table", :user_id => 0).save.delete
    
    hash={}
    data['items'].map do |k| 
      user_id_checkin_id =  self.user.id.to_s + "_" + k['id'].to_s
    
      f =  DataFoursquare.find_by_id(user_id_checkin_id)
    
      if f.nil? then
        case (k['type'])
        when "checkin"
          lat=k['venue']['location']['lat']
          lng=k['venue']['location']['lng']
          loc=k['venue']['location']
        else
          lat=k['location']['lat'] || 0
          lng=k['location']['lng'] || 0
          loc=k['location']['name'] || ""
        end
        u = DataFoursquare.new( :id => user_id_checkin_id, 
                              :date => k['createdAt'],
                              :timeZoneOffset => k['timeZoneOffset'], 
                              :latitude => lat, 
                              :longitude => lng, 
                              :location => loc.to_json, 
                              :user_id => self.user.id)
        u.save #|| raise("Error saving to DynamoDB")
      end
    end
  end
  
  def foursquare_info
    foursquare_user_info #.merge(foursquare_location_info)
  end
  
  def foursquare_location_info
    locations =  DataFoursquare.where(:user_id => self.user.id).all
    h={}
    locations.each do |locdata|
      data=Array.new
      data.push locdata.to_latlong_s
      data.push locdata.to_address_s
      h[locdata.to_time_s] = data.join(". ")
    end
    {"Checkins" => Hash[h.sort]}
  end
  
  def foursquare_user_info
    client = Foursquare2::Client.new(
      :oauth_token => self.device_authorization.auth_token)
    data = client.user("self")
    hash={}
    ['id', 'firstName', 'lastName', 'gender', 'homeCity', 'bio', 'contact'].map { |k| hash[k] = data[k]}
    {"User Info" => hash}
  end

  def is_location_device?
    true
  end
end
