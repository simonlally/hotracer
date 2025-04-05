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
FactoryBot.define do
  factory :race do
    
  end
end
