class AddTypeToDevices < ActiveRecord::Migration
  def up
    add_column :devices, :type, :string    
  end
  
  def down
    remove_column :devices, :type
  end
end
