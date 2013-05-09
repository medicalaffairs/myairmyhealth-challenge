class DataGPS
 
  # Tables defined in derived classes

  def gmaps4rails_address
    "#{self.location}" 
  end

  def gmaps4rails_infowindow
    "<b>Timestamp:</b> #{self.to_time_s}
    <br><b> Lat/Long:</b> #{self.to_latlong_s} 
    <br> #{self.to_address_s}"
  end

  def gmaps4rails_title
    "#{self.to_address_s}"
  end
  
  def gmaps4rails_sidebar
    "<span>#{self.to_time_s} : #{self.to_address_s}</span>" #put whatever you want here
  end

  def to_time_s
    Time.at(self.date).strftime "%Y/%m/%d - %H:%M:%S"
  end

  def to_latlong_s
    "("+self.latitude.round(3).to_s+", "+self.longitude.round(3).to_s+")"
  end

  def self.to_polyline(params)
    polyline = []
    
    params[:data].sort{|x,y| x.date <=> y.date }.each do |item|
      polyline.push ({:lng=>item.longitude.to_f,:lat=>item.latitude.to_f})
    end
    polylines = []
    polylines.push polyline
    polylines.to_json
  end

end