# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  firstname              :string(255)
#  lastname               :string(255)
#  birthday               :date
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#

require 'digest'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :password, :password_confirmation, :remember_me
  attr_accessible :email, :unconfirmed_email
  attr_accessible :birthday, :firstname, :lastname

  validates :firstname, :presence=> true, 
  						:length => { :maximum => 15 }

  has_many :devices, :dependent => :destroy
  has_many :device_authorizations, :through => :devices, :dependent => :destroy
end
