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

require 'zlib'
include Zlib

class DeviceBodymedia < Device

  
  def is_cardiac_device?
    true
  end
  
  def get_physiology_measures
    return ["Heart rate"]
  end

  def data(params={})
    measure_groups =  DataBodymedia.where(:user_id => self.user.id).all
    h={}
    h['Heart rate']={}
    measure_groups.each do |measure_group|
      uncompressed_data = JSON.parse(Inflate.inflate(Base64.decode64(measure_group[:heart_rate])))  
      uncompressed_data.map do | data_point |

        add_to_list = nil

        if params[:time_opts] then    
          if  (data_point['time'].to_i >= params[:time_opts][:start_date].to_i) && 
             (data_point['time'].to_i <= params[:time_opts][:end_date].to_i) then
            add_to_list = true      
          end
        else
          add_to_list = true
        end

        if add_to_list then
          h['Heart rate'][data_point['time']] = {:value => data_point['value'].to_s, :units => "bpm" }
        end
      end
    end
    
    number_of_days = ((params[:time_opts][:end_date].to_i-params[:time_opts][:start_date].to_i)/86400).to_i
    
    if number_of_days > 1
      hourly = (60*60).to_i
      new_h = {}
      (params[:time_opts][:start_date].to_i..params[:time_opts][:end_date].to_i).step(hourly) do |start_time|
        sub_h = h['Heart rate'].select { |k,v| (k.to_i >= start_time) && (k.to_i <= start_time+hourly) }
        beats, samples = sub_h.map { |k,v| [v[:value].to_f, 1] }.transpose
        unless samples.nil? 
          average = beats.inject(:+).to_f / samples.inject(:+)
          new_h[start_time] = { :value => average.round(1), :units => "bpm" }
        end
      end
      h['Heart rate'] = new_h
    end
    h.delete_if { |k, v| v.empty? }
  end


  def info
    data = super
    unless self.device_authorization.nil? 
      cache_data
      data.merge!(bodymedia_info)
    end
    return data
  end
 
  def bodymedia_info
    bodymedia_user_info.merge(bodymedia_measure_info)
  end
 
  def cache_data
#    tmp_file = '/tmp/data.json'
#    tmp_day_file = '/tmp/day-data.json'
    DataBodymedia.create(:id => "create_table", :user_id => 0).save.delete
 
    daily_data = JSON.parse(
        Bodymedia::Api.get_heart_rate_availability( { 
        :start_date => Time.now-30*24*60*60,
        :end_date => Time.now,
        :access_token => self.device_authorization.auth_token,
        :access_secret => self.device_authorization.auth_secret,
        :access_expiration => self.device_authorization.auth_expiration }) 
        )
# write 
#  File.open(tmp_file, 'w') {|f| f << daily_data.to_json}

#read
#    daily_data = JSON.parse File.read tmp_file

    daily_data['days'].map do |d| 

      unless d['sessions'].empty?

        user_id_date =  self.user.id.to_s + "_" + d['date'].to_s
      
        f =  DataBodymedia.find_by_id(user_id_date)
        if  (Time.now.strftime("%m") === d['date'][4..5]) && (Time.now.strftime("%d") === d['date'][6..7]) && f then
          f.delete
          f=nil
        end
        if f.nil? then

          yyyy= d['date'][0..3]
          mm= d['date'][4..5]
          dd= d['date'][6..7]
          
          heart_rate_data = []

         data = JSON.parse( Bodymedia::Api.get_heart_rate_data( { 
            :start_date => Time.local(yyyy,mm,dd),
            :end_date => Time.local(yyyy,mm,dd),
            :access_token => self.device_authorization.auth_token,
            :access_secret => self.device_authorization.auth_secret,
            :access_expiration => self.device_authorization.auth_expiration }))
      #write 
   #       File.open(tmp_day_file, 'w') {|f| f << data.to_json}
   #       data = JSON.parse File.read tmp_day_file
   
          data['days'].map do |day_data|
            day_data['sessions'].map do |data_session|
              data_session['details'].map do |data_point|
                data_point.delete('zone')
                heart_rate_data.push(data_point)
              end
            end
          end
        
          max_date =heart_rate_data.inject(0) { |max_date, point| (max_date < point['time'] ? point['time'] : max_date) }
        
          compressed_data = Base64.encode64(Deflate.deflate(heart_rate_data.to_json,BEST_COMPRESSION))

          u = DataBodymedia.new(:id => user_id_date, 
                              :date => max_date,
                              :heart_rate => compressed_data, 
                              :user_id => self.user.id)
          u.save || raise("Error saving to DynamoDB")
        end
      end
   end
 end

  def bodymedia_user_info
    data = Bodymedia::Api.get_user_info( { 
        :access_token => self.device_authorization.auth_token,
        :access_secret => self.device_authorization.auth_secret,
        :access_expiration => self.device_authorization.auth_expiration }) 
    {"User Info" => JSON.parse(data)}
  end

  def bodymedia_measure_info
    measure_groups =  DataBodymedia.where(:user_id => self.user.id).all
    h={}
    measure_groups.each do |measures|
      uncompressed_data = JSON.parse(Inflate.inflate(Base64.decode64(measures[:heart_rate])))
      uncompressed_data.take(50).map do | item |
        h[Time.at(item['time']).strftime "%Y/%m/%d - %H:%M:%S"] = item['value'].to_i
      end
    end
    {"Sample Heart Rate Data" => Hash[h.sort]}
  end

end

module Bodymedia
  module Api

    def self.get_user_info(params)
      params[:api_path]="/user/info"
      make_request(params);
    end

    def self.get_heart_rate_data(params)
      params[:api_path]="/heartrate/day/session/detail/zones"+Time.at(params[:start_date]).strftime("%Y%m%d")+"/"+Time.at(params[:end_date]).strftime("%Y%m%d")
      make_request(params);
    end

    def self.get_heart_rate_availability(params)
      params[:api_path]="/heartrate/day/session/zones"+Time.at(params[:start_date]).strftime("%Y%m%d")+"/"+Time.at(params[:end_date]).strftime("%Y%m%d")
      make_request(params);
    end

    def self.make_request(params)
      mykey=::Rails.application.config.bodymedia[:key]
      if Time.at(params[:access_expiration].to_i) <  Time.now() then
        new_token = accesstoken(params).get("https://api.bodymedia.com/oauth/access_token?api_key=#{mykey}").body
        new_keys = Rack::Utils.parse_nested_query new_token

        device_auth = DeviceAuthorization.where("auth_token = ? AND provider = ?", 
          params[:access_token], "bodymedia").update_all(
              :auth_token => new_keys["oauth_token"],
              :auth_secret => new_keys["oauth_token_secret"],
              :auth_expiration => new_keys["xoauth_token_expiration_time"])

        params[:access_token] = new_keys["oauth_token"]
        params[:access_secret] = new_keys["oauth_token_secret"]
      end
      accesstoken(params).get("https://api.bodymedia.com/v2/json#{params[:api_path]}?api_key=#{mykey}").body
    end

    def self.accesstoken(hash)
      OAuth::AccessToken.new(consumer, hash[:access_token], hash[:access_secret])
    end

    def self.consumer 
      OAuth::Consumer.new(::Rails.application.config.bodymedia[:key],
        ::Rails.application.config.bodymedia[:shared_secret], 
        {
          :site=>"https://api.bodymedia.com",
          :http_method        => :get,
          :request_token_path => "/oauth/request_token",
          :access_token_path  => "/oauth/access_token",
          :authorize_path     => "/oauth/authorize",
          :scheme => :header, 
          :oauth_version => "1.0"
        }
        )
    end
  end
end

