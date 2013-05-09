class DataWithings
  include Dynamoid::Document
  
  table :name => :withings_data, :key => :id #, :read_capacity => 400, :write_capacity => 400
  
  field :attribution, :integer
  field :category, :integer
  field :measures
  
  field :date, :integer
  
  index :date, :range => true
  
  field :user_id, :integer
  index :user_id
  
  has_one :device

end
