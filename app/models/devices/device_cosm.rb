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

class DeviceCosm < Device

  def is_air_quality_device?
    true
  end

  def get_air_quality_measures
    measure_groups =  DataCosm.where(:user_id => self.user.id).all
    h=[]
    measure_groups.each do |measures|
      h.push measures[:unit] unless h.include?(measures[:unit])
    end
    h
  end

  def data(params={})
    measure_groups =  DataCosm.where(:user_id => self.user.id).all
    h={}
    if measure_groups.nil? then 
      return h
    end
    h[params[:measure_type]]={}

    measure_groups.each do |measure_group|
      if (measure_group[:unit] == params[:measure_type]) then

        uncompressed_data = JSON.parse(Inflate.inflate(Base64.decode64(measure_group[:datapoints])))  
        uncompressed_data.map do | data_point |
          add_to_list = nil

          if params[:time_opts] then    
            if  (data_point['date'].to_i >= params[:time_opts][:start_date].to_i) && 
               (data_point['date'].to_i <= params[:time_opts][:end_date].to_i) then
              add_to_list = true      
            end
          else
            add_to_list = true
          end

          if add_to_list then
            h[measure_group[:unit]][data_point['date']] = {:value => data_point['value'].to_s, :units => measure_group[:unit] }
          end
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
          new_h[start_time] = { :value => average.round(2), :units => " " }
        end
      end
      h[params[:measure_type]] = new_h
    end
    h.delete_if { |k, v| v.empty? }
  end



	def info
    data = super
    unless self.device_authorization.nil? 
      cache_data
      data.merge!(cosm_info)
    end
    return data
  end

  def cosm_info
    cosm_user_info.merge(cosm_measure_info)
  end

  def get_title
    response =  JSON.parse Cosm::Client.get("/v2/feeds/#{self.device_authorization.uid}.json", :headers => {"X-ApiKey" => self.device_authorization.auth_token}).body
    response['title']
  end

  def cache_data
    DataCosm.create(:id => "create_table", :user_id => 0).save.delete

    time_step = 6*60*60 # 6 hours
    item_limit = 1000 
    how_far_back = 1*24*60*60 #2 days
    end_time = Time.now();
    start_time = end_time-time_step
    data_cache = {}

    until start_time < Time.now()-how_far_back do
      response =  JSON.parse Cosm::Client.get("/v2/feeds/#{self.device_authorization.uid}.json?limit=#{item_limit}&start=#{start_time.iso8601(0)}&end=#{end_time.iso8601(0)}&interval=0", :headers => {"X-ApiKey" => self.device_authorization.auth_token}).body
      
      earliest_time = Time.now();
      found_anything = nil
      if response.key?('datastreams') then
        response['datastreams'].map do |datastream| 
          if datastream.key?('datapoints') then
            datastream['datapoints'].map do |datapoint|
              found_anything = true
              this_time = Time.iso8601(datapoint['at'])
              (this_time < earliest_time) ? (earliest_time = this_time) : nil
              
#              puts datastream['id'] + " " + datapoint['value'] + " @ " + this_time.strftime("%Y/%m/%d - %H:%M:%S") + " " + datastream['unit']['label']
              
              data_struct = {:date => this_time.to_i, :value => datapoint['value']}
              unless data_cache.has_key?(this_time.strftime("%Y/%m/%d"))
                data_cache[this_time.strftime("%Y/%m/%d")] = {}
              end
              unless data_cache[this_time.strftime("%Y/%m/%d")].has_key?(datastream['id'])
                data_cache[this_time.strftime("%Y/%m/%d")][datastream['id']] = {:units => datastream['unit']['symbol'] || datastream['unit']['label'] || "", :datapoints => []}
              end
              data_cache[this_time.strftime("%Y/%m/%d")][datastream['id']][:datapoints].push data_struct              
            end
          end
        end
      end
      if found_anything
        end_time = earliest_time
        start_time = end_time - time_step
      else
        start_time = Time.now()-how_far_back-10000
      end
    end

    data_cache.each do |day, data|
      data.each do |stream_id, dataset|
          
          user_id_cosm_id_date =  self.user.id.to_s + "_" + self.device_authorization.uid + "_" + stream_id +"_" + day.to_s
        
          f = DataCosm.find_by_id(user_id_cosm_id_date) 
          unless f.nil?
            f.delete
          end

          compressed_data = Base64.encode64(Deflate.deflate(dataset[:datapoints].to_json,BEST_COMPRESSION))
          u = DataCosm.new( :id => user_id_cosm_id_date, 
                            :date => Time.utc(day[0..3],day[5..6],day[8..9]).to_i, 
                            :datastream => stream_id,
                            :datapoints => compressed_data,
                            :unit => dataset[:units],
                            :user_id => self.user.id)
          u.save || raise("Error saving to DynamoDB")
      end
    end
  end

  def cosm_user_info
    response =  JSON.parse Cosm::Client.get("/v2/feeds/#{self.device_authorization.uid}.json", :headers => {"X-ApiKey" => self.device_authorization.auth_token}).body
    hash={}
    ['id', 'title', 'website', 'tags', 'description', 'feed', 'status', 'creator','location'].map { |k| hash[k] = response[k]}
    response['datastreams'].map { |k| hash['datastream '+ k['id'].to_s] = k }
    {"Feed Info" => hash}
  end
 
  def cosm_measure_info
    measure_groups =  DataCosm.where(:user_id => self.user.id).all
    h={}
    measure_groups.each do |measures|
      uncompressed_data = JSON.parse(Inflate.inflate(Base64.decode64(measures[:datapoints])))
      uncompressed_data.take(50).each do | item |
        h["(#{measures[:datastream]}) "+ Time.at(item["date"]).strftime("%Y/%m/%d - %H:%M:%S")] = item["value"] + " " + measures[:unit]
      end
    end
    {"Sample Data" => Hash[h.sort]}
  end

end
