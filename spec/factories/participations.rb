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
FactoryBot.define do
  factory :participation do
    association :user
    association :race
    started_at { nil }
    finished_at { nil }
    words_per_minute { nil }
    placement { nil }
  end
end
