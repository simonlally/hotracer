# == Schema Information
#
# Table name: races
#
#  id         :integer          not null, primary key
#  body       :text             not null
#  slug       :string           not null
#  status     :string           default("pending"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  host_id    :integer          not null
#  winner_id  :integer
#
# Indexes
#
#  index_races_on_host_id    (host_id)
#  index_races_on_slug       (slug) UNIQUE
#  index_races_on_winner_id  (winner_id)
#
# Foreign Keys
#
#  host_id    (host_id => users.id)
#  winner_id  (winner_id => users.id)
#
class Race < ApplicationRecord
  belongs_to :host, class_name: "User", foreign_key: "host_id"
  belongs_to :winner, class_name: "User", foreign_key: "winner_id", optional: true

  has_many :participations, dependent: :destroy
  has_many :users, through: :participations

  VALID_STATUSES = %w[pending countdown in_progress finished].freeze

  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  scope :joinable, -> { where(status: :pending) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :finished, -> { where(status: :finished) }

  after_create_commit :enqueue_new_race_broadcast_job
  after_update_commit :broadcast_winner, if: :saved_change_to_winner_id?

  def can_be_started?(user)
    host_id == user.id && status == "pending"
  end

  def set_slug
    self.slug = SecureRandom.hex(10)
  end

  def formatted_paragraph_body
    body.split("").map do |char|
      "<span data-race-target='formattedChar'>#{char}</span>"
    end.join("")
  end

  def winning_participation
    participations
      .where(user: winner)
      .first
  end

  def pending?
    status == "pending"
  end

  def in_progress?
    status == "in_progress"
  end

  def finished?
    status == "finished"
  end

  private

  def enqueue_new_race_broadcast_job
    NewRaceBroadcastJob.perform_later(race_id: id)
  end

  def broadcast_winner
    broadcast_replace_to(
      self,
      target: "meat-and-potatoes",
      partial: "races/winner",
      locals: {
        winner: winner,
        winning_participation: winning_participation
      }
    )
  end
end
