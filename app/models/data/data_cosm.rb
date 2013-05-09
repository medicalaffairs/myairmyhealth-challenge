class DataCosm
  include Dynamoid::Document
 
  table :name => :cosm_data, :key => :id, :read_capacity => 100, :write_capacity => 100
   
  field :datapoints, :string
  field :unit, :string
  
  field :datastream, :string

  field :date, :integer
  index :date, :range => true

  field :user_id, :integer
  index :user_id
  
  has_one :device

end
