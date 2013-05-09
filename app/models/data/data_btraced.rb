class DataBtraced < DataGPS
  include Dynamoid::Document
  include Gmaps4rails::ActsAsGmappable
 
  table :name => :data_btraced, :key => :id 

  field :latitude, :float
  field :longitude, :float
  field :location, :string

  field :timeZoneOffset, :integer
  
  field :date, :integer
  index :date, :range => true
  
  field :user_id, :integer
  index :user_id
  
  has_one :device

  acts_as_gmappable :process_geocoding => false,
    :lat => 'latitude', :lon => 'longitude'
  
  def to_address_s
    "Latitude/Longitude: " + to_latlong_s
  end

  def self.search_by_date(params)
    #locs = self.where(  "date.gt" => params[:start_time].to_i, "id" => params[:user_id] ).all
    #,:user_id => params[:user_id],
  end
end
