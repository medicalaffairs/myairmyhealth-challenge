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

class DeviceNanotracer < Device
  
  def info
    a = DataNanotracer.create(:id => "create_table").save.delete
    data = super
    unless self.device_authorization.nil? 
      data.merge!(nanotracer_info)
    end
    return data
  end

  def get_air_quality_measures
    return ["Number concentration", "Average particle size","Air pollution index"]
  end

  def data(params={})
    measure_groups =  DataNanotracer.where(:sensor_id => self.device_authorization.uid).all
    h={}
    if measure_groups.nil? then 
      return h
    end
    h[params[:measure_type]]={}

    measure_groups.each do |data_point|

      add_to_list = nil

      if params[:time_opts] then    
        if  (data_point[:date].to_i >= params[:time_opts][:start_date].to_i) && 
           (data_point[:date].to_i <= params[:time_opts][:end_date].to_i) then
          add_to_list = true      
        end
      else
        add_to_list = true
      end

      if add_to_list then
        altered_time = data_point[:date].to_i + 14400
        case params[:measure_type]
        when "Number concentration" 
          h[params[:measure_type]][altered_time] = {:value => data_point[:numConcentration].to_s, :units => "particles/cm^3"} unless data_point[:numConcentration].nil?
        when "Average particle size" 
          h[params[:measure_type]][altered_time] = {:value => data_point[:avgParticleSize].to_s, :units => "nm"} unless data_point[:avgParticleSize].nil?
        when "Air pollution index" 
          h[params[:measure_type]][altered_time] = {:value => data_point[:airPollutionIndex].to_s, :units => ""} unless data_point[:airPollutionIndex].nil?
        end
      end
    end

    number_of_days = ((params[:time_opts][:end_date].to_i-params[:time_opts][:start_date].to_i)/86400).to_i
    
    if number_of_days > 1
      hourly = (60*60).to_i
      new_h = {}
      (params[:time_opts][:start_date].to_i..params[:time_opts][:end_date].to_i).step(hourly) do |start_time|
        sub_h = h[params[:measure_type]].select { |k,v| (k.to_i >= start_time) && (k.to_i <= start_time+hourly) }
        beats, samples = sub_h.map { |k,v| [v[:value].to_f, 1] }.transpose

        unless samples.nil? 
          average = beats.inject(:+).to_f / samples.inject(:+)
          new_h[start_time+14400] = { :value => average.round(2), :units => h[params[:measure_type]].values.first[:units] }
        end
      end
      h[params[:measure_type]] = new_h
    end
    h.delete_if { |k, v| v.empty? }
  end





  def self.add_data_from_file(uploaded_file)
    counter = 0
    header = units = measures =nil;
    file_data={}
    file_data[:data]=[]
    File.open(uploaded_file.tempfile) do |file|
      while (line = file.gets)
        header = true if line =~ /\[Device/ 
        units = true if line =~ /\[Units/ 
        measures =true if line =~ /\[Measurements/
 
        if measures
          units=nil
          if line =~ /\[Measurements/ 
            header_array = file.gets.chomp.split(/\t/)
          else
            counter=0
            hash ={}
            vals = line.split(/\t/)
            header_array.each do |d|
              hash.merge!( { d => vals[counter] } )
              counter +=1
            end

            file_data[:data].push hash
          end
        end
        if units
          header=nil 
        end
        if header then
            file_data[:serial_number]= line.scan(/SH.+/).first.gsub(/\r/,'')  if line =~ /Ser. nr. engine/
            file_data[:start_date] = line.scan(/\t.+ [0-9]+, [0-9]+ .* [AP]M/).first.gsub(/\t/,'')    if line =~ /Start date/
        end
          
        counter = counter + 1
      end #your stuff goes here
    end 
    file_data[:data].each do |data_point|  
      data_point["time"]= Time.parse(data_point["date(1)"].to_s+"T"+data_point["time(1)"].to_s).utc.to_i
      data_point.delete("date(1)")
      data_point.delete("time(1)")
    end

    file_data[:data].each do |pt|
        utc_epoch = pt["time"].to_i
        datestr = Time.at(utc_epoch).strftime "%Y/%m/%d - %H:%M:%S"

        sensor_id_time_id =   file_data[:serial_number].to_s + "_" + utc_epoch.to_s 

        f =  DataNanotracer.find_by_id(sensor_id_time_id)
        if f.nil? then
          #case sampling_mode
          #when "1"
            options = { :id => sensor_id_time_id, 
                            :date => utc_epoch.to_i,
                            #:timeZoneOffset => datahash[:bwiredtravel][:timeOffset], 
                            :numConcentration => pt["N(1)"], 
                            :avgParticleSize => pt["dp_av(1)"], 
                            :airPollutionIndex => pt["P(1)"], 
                            :sensor_id => file_data[:serial_number].to_s }
         # when "2"
         #   options = { :id => sensor_id_time_id, 
         #                   :date => utc_epoch.to_i,
         #                   #:timeZoneOffset => datahash[:bwiredtravel][:timeOffset], 
         #                   :numConcentration => pt["N(1)"], 
         #                   :airPollutionIndex => pt["P(1)"], 
         #                   :appNumConcentration => pt[:appNumConcentration],
         #                   :sensor_id => device_serial_number.to_s}
         # else
         #   throw :errorRequested, "Unsupported Nanotracer sampling_mode"
         # end  
          u = DataNanotracer.new( options )   
          unless u.save 
            throw :errorRequested, "Unable to save Nanotracer datapoint"
          end
        end
      end

  end

  def self.add_data(datahash)
    
    answer ={}
    answer[:id]=0
    answer[:valid]=true 
    answer[:groupid]=-1
 
    error_message = catch (:errorRequested) {
      
      saved_points = Array.new

      if datahash.nil? || datahash[:nanoreporter].nil? then
        throw :errorRequested, "XML not in expected format for NanoReporter"
      end

      device_serial_number = datahash[:nanoreporter][:devId]
      sampling_mode = datahash[:nanoreporter][:mode]

      answer[:groupid]=datahash[:nanoreporter][:measurements][:groupid].to_i

      datahash[:nanoreporter][:measurements][:measure].each do |pt|
        utc_epoch = pt[:time].to_i
        datestr = Time.at(utc_epoch).strftime "%Y/%m/%d - %H:%M:%S"

        sensor_id_time_id =   device_serial_number.to_s + "_" + utc_epoch.to_s 

        f =  DataNanotracer.find_by_id(sensor_id_time_id)
        if f.nil? then
          case sampling_mode
          when "1"
  	        options = { :id => sensor_id_time_id, 
                            :date => utc_epoch.to_i,
                            #:timeZoneOffset => datahash[:bwiredtravel][:timeOffset], 
                            :numConcentration => pt[:numConcentration], 
                            :avgParticleSize => pt[:avgParticleSize], 
                            :airPollutionIndex => pt[:airPollutionIndex], 
                            :sensor_id => device_serial_number.to_s }
          when "2"
  		      options = { :id => sensor_id_time_id, 
                            :date => utc_epoch.to_i,
                            #:timeZoneOffset => datahash[:bwiredtravel][:timeOffset], 
                            :numConcentration => pt[:numConcentration], 
                            :airPollutionIndex => pt[:airPollutionIndex], 
                            :appNumConcentration => pt[:appNumConcentration],
                            :sensor_id => device_serial_number.to_s}
          else
            throw :errorRequested, "Unsupported Nanotracer sampling_mode"
  		    end  
          u = DataNanotracer.new( options )  	
          if u && u.save 
            saved_points.push pt[:id].to_i
          end
        end
      end

      answer[:points]=saved_points
    	return answer.to_json
    }

    answer[:error]=true
    answer[:message]=error_message
    return answer.to_json
  end
    
  def nanotracer_info
    nanotracer_user_info.merge(nanotracer_data)
  end

  def nanotracer_user_info
    hash={}
    hash["Callback URL"] = "https://"+::Rails.application.config.action_mailer.default_url_options[:host]+"/nanotracer/"+self.device_authorization.uid
    {"User Info" => hash}
  end

  def nanotracer_data
    DeviceAuthorization
    data_points =  DataNanotracer.where(:sensor_id => self.device_authorization.uid).all
    h={}
    data_points.each do |data_point|
      h[data_point.to_time_s] = data_point.to_s
    end
    {"Sensor Data" => Hash[h.sort]}
  end

  def is_air_quality_device?
    true
  end

end
