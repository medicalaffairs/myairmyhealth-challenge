# == Schema Information
#
# Table name: device_authorizations
#
#  id              :integer          not null, primary key
#  provider        :string(255)
#  uid             :string(255)
#  user_id         :integer
#  auth_token      :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  auth_secret     :string(255)
#  auth_expiration :string(255)
#

class DeviceAuthorization < ActiveRecord::Base
  has_many :devices, :dependent => :destroy
  
  attr_accessible :provider, :uid, :auth_token, :user_id
  
  def info
     data = { "OAuth Provider" =>  self[:provider], "OAuth UID" => self[:uid],  
      #{}"OAuth Token" => self[:auth_token] 
      }
  end
     
  def self.create_or_update_from_hash(hash, current_user)
    device_authorization = where( :provider => hash['provider'], :uid => hash['uid'], 
      :user_id => current_user).first_or_create(:auth_token => hash['credentials']['token'])
    
    device_authorization.auth_token = hash['credentials']['token'] || 0
    device_authorization.auth_secret = hash['credentials']['auth_secret'] || 0 
    device_authorization.auth_expiration = hash['credentials']['auth_expiration'] || 0 
    
    begin
      device_authorization.save 
    rescue
     raise "An error creating a device authorization has occured"
    end
    
    if hash['provider']=='singly'
      x=hash['extra']['raw_info']
      x.each do |k,v|
        devices = User.find(current_user).devices.where(" is_authorized = 0 AND lower(devicename) = ?", k.downcase) 
        devices.each do |d|
          d.device_authorization = device_authorization
          d.is_authorized = 1
          d.save
        end
      end
    elsif hash['provider'] == 'foursquare'
        devices = User.find(current_user).devices.where(" is_authorized = 0 AND lower(devicename) = ?", 'foursquare (gps)') 
        devices.each do |d|
          d.device_authorization = device_authorization
          d.is_authorized = 1
          d.save
        end
    elsif hash['provider'] == 'cosm'
        devices = User.find(current_user).devices.where(" is_authorized = 0 AND lower(devicename) = ?", 'cosm feed') 
        devices.each do |d|
          d.device_authorization = device_authorization
          d.is_authorized = 1
          d.devicename = d.get_title
          d.save
        end
    elsif hash['provider'] == 'bodymedia'
        devices = User.find(current_user).devices.where(" is_authorized = 0 AND lower(devicename) = ?", 'bodymedia') 
        devices.each do |d|
          d.device_authorization = device_authorization
          d.is_authorized = 1
          d.save
        end
    elsif hash['provider'] == 'btraced'
        devices = User.find(current_user).devices.where(" is_authorized = 0 AND lower(devicename) = ?", 'btraced (gps)') 
        devices.each do |d|
          d.device_authorization = device_authorization
          d.is_authorized = 1
          d.save
        end
    elsif hash['provider'] == 'nanotracer'
        devices = User.find(current_user).devices.where(" is_authorized = 0 AND lower(devicename) = ?", 'nanotracer') 
        devices.each do |d|
          d.device_authorization = device_authorization
          d.is_authorized = 1
          d.save
        end
    elsif hash['provider'] == 'respiratory'
        devices = User.find(current_user).devices.where(" is_authorized = 0 AND lower(devicename) = ?", 'respiratory flow meter') 
        devices.each do |d|
          d.device_authorization = device_authorization
          d.is_authorized = 1
          d.save
        end
    end

    true
  end  
  
  def self.get_auth_token(params) 
    set_of_authorizations = DeviceAuthorization.where(:user_id => params[:user], :provider => params[:provider]) #%User.find(params[:user]).device_authorizations.where(:provider => params[:provider]) 
    return set_of_authorizations.map {|a| a.auth_token}.uniq
  end
end
