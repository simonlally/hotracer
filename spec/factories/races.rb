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
FactoryBot.define do
  factory :race do
    
  end
end
