class AirQualityController < ApplicationController
 
  before_filter :authenticate_user!

  def date_value_hash_to_float_array(a) 
    a.collect { |k,v| [k*1000, v[:value].to_f] }.sort
  end

  def data
    @user = User.find(current_user)
    @sample = {}
    
    air_quality_device_options  = JSON.parse(params['air_quality_menu_options']) || nil
    time_options  = JSON.parse(params['time_menu_options']) || nil
    @options = {}
    if time_options then
      @options[:time_opts] = { :start_date => time_options['start_date'], :end_date => time_options['end_date'] }
    end

    air_quality_device_options.each do |v|
      if v['selected'] == true
        device_to_sample = Device.where("id = ? and user_id = ?", v['device_id'], current_user.id).all
        unless device_to_sample.nil?
          if @sample[v['device_id']].nil?
            @sample[v['device_id']]={}
          end
          device_to_sample.each do |d|
            @sample[v['device_id']][v['measure_type']] = d.data( @options.merge( {:measure_type => v['measure_type']} ) )
          end
        end
      end
    end

    @chart = LazyHighCharts::HighChart.new('air_graph')  do |f|
      f.title({ :text=> ""})
      f.options[:xAxis] = {
                            :type => "datetime",
                            :dateTimeLabelFormats => {   :month => '%e %b',  :year => '%b' } 
                          }


      @axes ={}
      @sample.map do |device, measures| 
        measures.map do |measure_name, data_sets|
            @axes[measure_name]=true
        end
      end 

      @yaxis = []
      @axes.map do |k,v|
         @yaxis.push( { :title => {text: k } }) 
      end
      f.options[:yAxis] = @yaxis

      @sample.map do |device, measures| 
        measures.map do |measure_name, data_sets|   
          unless data_sets.nil?
            data_sets.map do |parameter_name, data|
             units =  data.first[1][:units].to_s
             
               f.series(:type=> 'line', :name=>  parameter_name.to_s + " (#{units})",
                  :marker => {:enabled => false},
                 :tooltip => {:pointFormat => "{series.name}: <b>{point.y}</b> "+ units +"<br/>"},
                 :data=> date_value_hash_to_float_array(data_sets[parameter_name]),
                 :yAxis => find_axis(@yaxis,parameter_name) )
             
            end
          end
        end
      end
      

      f.options[:chart][:renderTo] = "air_quality_chart"
      f.options[:tooltip] = { :formatter => "" }
    end  
 
    respond_to do |format|
    format.js 
    return
    end    
  end


  def find_axis(axis, name) 
    @found=nil
    i = axis.inject(0) do |c, v|
      if v[:title][:text] == name then  @found = true end
      c + ( @found ? 0 : 1 )
    end
  end

end
