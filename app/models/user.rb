# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :hosted_races, class_name: "Race", foreign_key: "host_id", dependent: :destroy
  has_many :races, through: :participations

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :password_digest, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
