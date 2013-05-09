class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string    :devicename
      t.integer   :user_id
      t.integer   :device_authorization_id
      t.integer   :is_authorized
      t.timestamps
    end
  end
end
