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

require 'withings-api'
require 'data_withings'

class DeviceWithings < Device
  
  def is_cardiac_device?
    true
  end
  
  def get_physiology_measures
    return ["Heart rate", "Blood pressure", "Weight"]
  end
  
  def data(params={})

    measure_groups =  DataWithings.where(:user_id => self.user.id).all
    h={}
    h['Heart rate']={}
    h['Diastolic']={}
    h['Systolic']={}
    h['Weight']={}
    measure_groups.each do |measure_group|
      (JSON.load measure_group[:measures]).each do |m|
        data_point=Withings::Api::Measurement.new(m)
       
        add_to_list = nil

        if params[:time_opts] then    
          if  (measure_group[:date].to_i >= params[:time_opts][:start_date].to_i) && 
             (measure_group[:date].to_i <= params[:time_opts][:end_date].to_i) then
            add_to_list = true      
          end
        else
          add_to_list = true
        end

        if add_to_list then
          measure_type = data_point.measurement_type.to_query_param_value
         
          case params[:measure_type]
            when "Heart rate" 
              if measure_type == 11
                h['Heart rate'][measure_group[:date]] = {:value => data_point.value.round(1).to_s, :units => "bpm" }
              end
            when "Blood pressure"
              if measure_type == 9
                h['Diastolic'][measure_group[:date]] = {:value => data_point.value.round(1).to_s, :units => "mmHg" }
              end            
              if measure_type == 10
                h['Systolic'][measure_group[:date]] = {:value => data_point.value.round(1).to_s, :units => "mmHg" }
              end            
            when "Weight"
              if measure_type == 1
                h['Weight'][measure_group[:date]] = {:value => data_point.value.round(1).to_s, :units => "kg" }
              end      
          end
        end
      end
    end
    h.delete_if { |k, v| v.empty? }

  end

  def info
    data = super
    unless self.device_authorization.nil? 
      cache_data
      data.merge!(withings_info)
    end
    return data
  end
   
  def cache_data
    data = Withings::Api.singly_measure_getmeas :access_token => self.device_authorization.auth_token
    
    a = DataWithings.create(:id => "test", :user_id => 0).save.delete
    
    hash={}
    data.measure_groups.each do |group|
      user_id_group_id =  self.user.id.to_s + "_" + group.id.to_s
    
      f =  DataWithings.find_by_id(user_id_group_id)        
      if f.nil? then
        u = DataWithings.new( :id => user_id_group_id, :date => group.date, :attribution => group.attribution.to_query_param_value, \
                              :category => group.category.to_query_param_value, :measures => group.measurements.to_json, :user_id => self.user.id)
        u.save #|| raise("Error saving to DynamoDB")
      end
    end
  end
  
  def withings_info
    withings_user_info.merge(withings_measure_info)
  end
  
  def withings_measure_info
    measure_groups =  DataWithings.where(:user_id => self.user.id).all
    h={}
    measure_groups.each do |measure_group|
      data=Array.new
      (JSON.load measure_group[:measures]).each do |m|
        tmp=Withings::Api::Measurement.new(m)
        data.push (tmp.measurement_type.description + " " + tmp.value.round(1).to_s)
      end
      h[Time.at(measure_group[:date]).strftime "%Y/%m/%d - %H:%M:%S" + 
      " (" + measure_group[:id].gsub!(/[0-9]+_/,"").to_s + ")"] = data.join(". ")
    end
    {"Cached Data" => Hash[h.sort]}
  end
  
  def withings_raw_measure_info
     measure_groups =  DataWithings.where(:user_id => self.user.id).all
     hash={}
     measure_groups.each do |measure_group|
       hash[measure_group.id]={}
       measure_group.attributes.each do |k,v|
         case k
         when :measures 
           hash[measure_group.id][k]=Array.new
           (JSON.load v).each do |m|
             hash[measure_group.id][k].push Withings::Api::Measurement.new(m)
          end
         else 
           hash[measure_group.id][k]=v
         end
       end
     end
     {"Raw Measure Data" => hash}
   end
  
  def withings_user_info
    begin
      data = Withings::Api.singly_user_self :access_token => self.device_authorization.auth_token
    rescue
      data = Withings::Api.singly_user_self :access_token => self.device_authorization.auth_token
    end  
    hash={}
    data.user.instance_variables.each { |var| hash[var.to_s.delete("@")] = data.user.instance_variable_get(var).inspect }
    hash["birthdate"] = Time.at( hash["birthdate"].to_i ).strftime "%Y/%m/%d" 
    {"User Info" => hash}
  end

end
