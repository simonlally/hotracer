# == Schema Information
#
# Table name: races
#
#  id                  :integer          not null, primary key
#  body                :text             not null
#  duration_in_seconds :integer
#  slug                :string           not null
#  started_at          :datetime
#  status              :string           default("pending"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  host_id             :integer          not null
#
class Race < ApplicationRecord
  belongs_to :host, class_name: "User", foreign_key: "host_id"

  has_many :participations, dependent: :destroy
  has_many :users, through: :participations

  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true

  # enum status: { pending: "pending", countdown: "countdown", in_progress: "in_progress" }

  scope :joinable, -> { where(status: :pending) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :finished, -> { where(status: :finished) }

  after_create_commit { broadcast_append_to "races", target: "races" }

  def can_be_started?(user)
    host_id == user.id && status == "pending"
  end

  def set_slug
    self.slug = SecureRandom.hex(10)
  end

  def duration_in_minutes
    duration_in_seconds / 60
  end

  def started?
    started_at.present?
  end

  def finished?
    finished_at.present?
  end

  def in_progress?
    status == "in_progress"
  end
end
