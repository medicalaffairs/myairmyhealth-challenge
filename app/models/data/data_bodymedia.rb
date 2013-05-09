class DataBodymedia
  include Dynamoid::Document
 
  table :name => :bodymedia_data, :key => :id
   
  field :heart_rate, :serialized

  field :date, :integer
  index :date, :range => true

  field :user_id, :integer
  index :user_id
  
  has_one :device

end
