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
#
# Indexes
#
#  index_races_on_host_id  (host_id)
#  index_races_on_slug     (slug) UNIQUE
#
# Foreign Keys
#
#  host_id  (host_id => users.id)
#
require 'rails_helper'

RSpec.describe Race, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
