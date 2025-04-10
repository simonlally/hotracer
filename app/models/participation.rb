# == Schema Information
#
# Table name: participations
#
#  id               :integer          not null, primary key
#  finished_at      :datetime
#  placement        :integer
#  started_at       :datetime
#  words_per_minute :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  race_id          :integer          not null
#  user_id          :integer          not null
#
# Indexes
#
#  index_participations_on_race_id  (race_id)
#  index_participations_on_user_id  (user_id)
#
# Foreign Keys
#
#  race_id  (race_id => races.id)
#  user_id  (user_id => users.id)
#
class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :race

  validates_associated :user
  validates_associated :race

  after_create_commit -> { broadcast_participation }
  after_update_commit -> { broadcast_participation if saved_change_to_placement? }

  scope :finished, -> { where.not(finished_at: nil, placement: nil) }

  delegate :email_address, to: :user

  private

  def broadcast_participation
    broadcast_append_to(
      race,
      target: "participations",
      partial: "participations/participation",
      locals: { participation: self }
    )
  end
end
