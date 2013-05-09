class AddOauthParamsToDeviceAuthorization < ActiveRecord::Migration
  def up
    add_column :device_authorizations, :auth_secret, :string
    add_column :device_authorizations, :auth_expiration, :string
  end
 
  def down
    remove_column :device_authorizations, :auth_secret
    remove_column :device_authorizations, :auth_expiration
  end
end
