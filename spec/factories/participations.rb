# == Schema Information
#
# Table name: participations
#
#  id               :integer          not null, primary key
#  accuracy         :integer
#  finished_at      :datetime
#  placed           :integer
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
    
  end
end
