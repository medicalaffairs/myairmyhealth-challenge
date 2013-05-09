class DataRespiratory
  include Dynamoid::Document
 
  table :name => :respiratory_data, :key => :id
   
  field :fev1, :float
  field :fev6, :float
  field :pef, :float
  field :fvc, :float

  field :date, :integer
  index :date, :range => true
  
  field :user_id, :integer
  index :user_id
  
  has_one :device

end
