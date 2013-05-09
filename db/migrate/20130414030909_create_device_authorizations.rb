class CreateDeviceAuthorizations < ActiveRecord::Migration
  def change
    create_table :device_authorizations do |t|
      t.string :provider
      t.string :uid
      t.integer :user_id
      t.string :auth_token
      t.timestamps
    end
  end
end
