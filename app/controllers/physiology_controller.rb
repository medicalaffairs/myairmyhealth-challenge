class PhysiologyController < ApplicationController
 
  before_filter :authenticate_user!

  def date_value_hash_to_float_array(a) 
    a.collect { |k,v| [k*1000, v[:value].to_f] }.sort
  end

	def data
    @user = User.find(current_user)
    @sample = {}
    
    physiology_device_options  = JSON.parse(params['physiology_menu_options']) || nil
    time_options  = JSON.parse(params['time_menu_options']) || nil
    @options = {}
    if time_options then
      @options[:time_opts] = { :start_date => time_options['start_date'], :end_date => time_options['end_date'] }
    end

    physiology_device_options.each do |v|
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


    @chart = LazyHighCharts::HighChart.new('physiology_canvas')  do |f|
      f.title({ :text=> ""})
      f.options[:xAxis] = {
                            :type => "datetime",
                            :dateTimeLabelFormats => {   :month => '%e %b',  :year => '%b' } 
                          }


      @axes ={}
      @sample.map do |device, measures| 
        measures.map do |measure_name, data_sets|
          case measure_name
            when "Heart rate" 
              @axes[:HRBP]=true
            when "Blood pressure" 
              @axes[:HRBP]=true 
            when "Weight"
              @axes[:Weight]=true
            when "FEV1"
              @axes[:FEVFVC]=true
            when "FEV6"
              @axes[:FEVFVC]=true
            when "FVC"
              @axes[:FEVFVC]=true
            when "PEF"
              @axes[:PEF]=true
          end
        end
      end 

      @yaxis = []
      if @axes[:HRBP] then  @yaxis.push( { :title => {text: 'Heart rate / Blood Pressure' } }) end  
      if @axes[:Weight] then   @yaxis.push( { :title => {text: 'Weight'}, :opposite => true, :minRange => 20 } )  end
      if @axes[:FEVFVC] then   @yaxis.push( { :title => {text: 'FEV1 / FEV6 / FVC'}, :opposite => true } )  end
      if @axes[:PEF] then   @yaxis.push( { :title => {text: 'PEF'}, :opposite => true } )  end
      f.options[:yAxis] = @yaxis
      

      @sample.map do |device, measures| 
        measures.map do |measure_name, data_sets|   
          unless data_sets.nil?
            data_sets.map do |parameter_name, data|
             units =  data.first[1][:units].to_s
             if measure_name == "Heart rate"
               f.series(:type=> 'line', :name=>  parameter_name.to_s + " (#{units})",
                  :marker => {:enabled => false},
                 :tooltip => {:pointFormat => "{series.name}: <b>{point.y}</b> "+ units +"<br/>"},
                 :data=> date_value_hash_to_float_array(data_sets[parameter_name]),
                 :yAxis => find_axis(@yaxis,parameter_name) )
             else
               f.series(:type=> 'line', :name=>  parameter_name.to_s + " (#{units})",
                 :tooltip => {:pointFormat => "{series.name}: <b>{point.y}</b> "+ units +"<br/>"},
                 :data=> date_value_hash_to_float_array(data_sets[parameter_name]),
                 :yAxis => find_axis(@yaxis,parameter_name) )
             end
            end
          end
        end
      end
      

      f.options[:chart][:renderTo] = "physiology_chart"
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
      case name
      when "Heart rate"
        if v[:title][:text] == 'Heart rate / Blood Pressure' then  @found = true end
      when "Diastolic"
         if v[:title][:text] == 'Heart rate / Blood Pressure' then  @found = true end
      when "Systolic"
        if v[:title][:text] == 'Heart rate / Blood Pressure' then @found = true end
      when "Weight"
        if v[:title][:text] == "Weight" then @found = true end
      when "FEV1"
        if v[:title][:text] == "FEV1 / FEV6 / FVC" then @found = true end
      when "FEV6"
        if v[:title][:text] == "FEV1 / FEV6 / FVC" then @found = true end
      when "FVC"
        if v[:title][:text] == "FEV1 / FEV6 / FVC" then @found = true end
      when "PEF"
        if v[:title][:text] == "PEF" then @found = true end
      end
      c + ( @found ? 0 : 1 )
    end
  end

end
