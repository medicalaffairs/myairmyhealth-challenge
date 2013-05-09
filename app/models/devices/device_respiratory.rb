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

class DeviceRespiratory < Device

  def get_physiology_measures
    return ["FEV1", "FEV6", "FVC", "PEF"]
  end

  def info
    data = super
    unless self.device_authorization.nil? 
      a = DataRespiratory.create(:id => "create_table", :user_id => 0).save.delete
      data.merge!(respiratory_info)
    end
    return data
  end
 
  def data(params={})
    measure_groups =  DataRespiratory.where(:user_id => self.user.id).all
    h={}
    h['FEV1']={}
    h['FEV6']={}
    h['FVC']={}
    h['PEF']={}

    measure_groups.each do |data_point|

        add_to_list = nil

        if params[:time_opts] then    
          if (data_point['date'].to_i >= params[:time_opts][:start_date].to_i) && 
             (data_point['date'].to_i <= params[:time_opts][:end_date].to_i) then
            add_to_list = true      
          end
        else
          add_to_list = true
        end

        if add_to_list then
          case params[:measure_type]
          when "FEV1"
            h[params[:measure_type]][data_point['date']] = {:value => data_point['fev1'].to_s, :units => "L" } unless data_point['fev1'].nil?
          when "FEV6"
            h[params[:measure_type]][data_point['date']] = {:value => data_point['fev6'].to_s, :units => "L" } unless data_point['fev6'].nil?
          when "PEF"
            h[params[:measure_type]][data_point['date']] = {:value => data_point['pef'].to_s, :units => "L/s" } unless data_point['pef'].nil?
          when "FVC"
            h[params[:measure_type]][data_point['date']] = {:value => data_point['fvc'].to_s, :units => "L" } unless data_point['fvc'].nil?
          end
        end
      end
    h.delete_if { |k, v| v.empty? }
  end


  def add_data(datahash)
   
    answer ={}
    answer[:id]=0
    answer[:valid]=true 
    answer[:groupid]=-1
 puts datahash.inspect
    error_message = catch (:errorRequested) {
      
      saved_points = Array.new

      if datahash.nil? || datahash["respiratory"].nil? then
        throw :errorRequested, "XML not in expected format for Respiratory Flow Meter"
      end

      device_serial_number = datahash["respiratory"]["devId"]

      answer[:groupid]=datahash["respiratory"]["measurements"]["groupid"].to_i

        utc_epoch = Time.iso8601(datahash["respiratory"]["measurements"]["measure"]["time"])

        datestr = Time.at(utc_epoch).strftime "%Y/%m/%d - %H:%M:%S"

        user_id_time_id =  self.user.id.to_s + "_" + utc_epoch.to_i.to_s + "_" + device_serial_number.to_s

        f =  DataRespiratory.find_by_id(user_id_time_id)
        if f.nil? then
	        options = { :id => user_id_time_id, 
                          :date => utc_epoch.to_i,
                          :fev1 => datahash["respiratory"]["measurements"]["measure"]["fev1"]||nil,
                          :fev6 => datahash["respiratory"]["measurements"]["measure"]["fev6"]||nil,
                          :fvc => datahash["respiratory"]["measurements"]["measure"]["fvc"]||nil,
                          :pef => datahash["respiratory"]["measurements"]["measure"]["pef"]||nil,
                          :user_id => self.user.id }
                          puts options.inspect
          u = DataRespiratory.new( options )  	
          if u && u.save 
            saved_points.push datahash["respiratory"]["measurements"]["measure"]["id"].to_i
          end

      end

      answer[:points]=saved_points
    	return answer.to_json
    }

    answer[:error]=true
    answer[:message]=error_message
    return answer.to_json
  end
    
  def respiratory_info
    respiratory_user_info
  end

  def respiratory_user_info
    hash={}
    hash["Callback URL"] = "https://"+::Rails.application.config.action_mailer.default_url_options[:host]+"/respflowdata/"+self.device_authorization.uid
    {"User Info" => hash}
  end

  def is_respiratory_device?
    true
  end

end
