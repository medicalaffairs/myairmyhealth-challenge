# == Schema Information
#
# Table name: device_authorizations
#
#  id              :integer          not null, primary key
#  provider        :string(255)
#  uid             :string(255)
#  user_id         :integer
#  auth_token      :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  auth_secret     :string(255)
#  auth_expiration :string(255)
#

require 'spec_helper'

describe DeviceAuthorization do
  pending "add some examples to (or delete) #{__FILE__}"
end
