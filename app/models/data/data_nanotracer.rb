class DataNanotracer
  include Dynamoid::Document
 
  table :name => :nanotracer_data, :key => :id, :read_capacity => 400, :write_capacity => 400
   
  field :numConcentration, :float
  field :avgParticleSize, :float
  field :airPollutionIndex, :float
  field :appNumConcentration, :float

  field :date, :integer
  index :date, :range => true
  
  field :sensor_id, :string
  index :sensor_id
  
  has_one :device

  def to_time_s
    Time.at(self.date).strftime "%Y/%m/%d - %H:%M:%S"
  end

  def to_s
    (self.numConcentration ? " N = " + self.numConcentration.round(0).to_s : "" )+ 
    (self.avgParticleSize ? " dPavg = " +  self.avgParticleSize.round(2).to_s : "" ) +
    (self.airPollutionIndex ? " P = " +  self.airPollutionIndex.round(2).to_s : "" ) +
    (self.appNumConcentration ? " N(app) = " +  self.appNumConcentration.round(2).to_s : "")
  end
end
