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

class Device < ActiveRecord::Base
  belongs_to :user
  belongs_to :device_authorization
  
  attr_accessible :devicename, :user_id, :device_authorization_id, :is_authorized, :type
  
  def self.remaining_options(this_user)

    options = all_options
    this_user.devices.each do |d|
      options.delete(d.devicename)
    end
    options
  end
  
  def self.all_options
    options = ["Withings", "BodyMedia", "Btraced (GPS)", "Foursquare (GPS)", "NanoTracer", "Respiratory Flow Meter", "Cosm Feed"]#, ,  "Twitter", "FitBit", "Nike", "Garmin GPS Watch"]
  end
  
  def info
    data = { "Device Name" =>  self[:devicename], "Registered on" => self[:created_at], 
      "Device authorization" => (self[:is_authorized]==0? "not ": "" ) +"completed" }  
    
    unless self.device_authorization.nil? 
      data.merge!({"OAuth Details" => self.device_authorization.info})
    end

    data
  end
  
  def is_location_device?
    nil
  end

  def is_air_quality_device?
    nil
  end

  def is_respiratory_device?
    nil
  end

  def is_cardiac_device?
    nil
  end

  def get_physiology_measures
    nil
  end
  
  def get_air_quality_measures
    nil
  end

  def is_physiology_device?
    return is_respiratory_device? || is_cardiac_device?
  end

  def self.get_devices(device_type, user)
    set_of_devices = []
    Device.where(:user_id => user.id).each do |d|
      case device_type
        when :location
          if d.is_location_device? then
            set_of_devices.push(d)
          end
        when :physiology
          if d.is_physiology_device? then
            set_of_devices.push(d)
          end 
        when :air_quality
          if d.is_air_quality_device? then
            set_of_devices.push(d)
          end  
      end 
    end
    return set_of_devices
  end
  
end
