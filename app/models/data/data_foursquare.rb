class DataFoursquare < DataGPS
  include Dynamoid::Document
  include Gmaps4rails::ActsAsGmappable

  table :name => :foursquare_data, :key => :id 
 
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
    locstring = JSON.load self.location
    [ [ locstring['address'], locstring['crossStreet']].join(" "), 
      locstring['city'], locstring['state'],
      locstring['country'], locstring['postalCode'] 
    ].join(", ") 
  end

  
end
