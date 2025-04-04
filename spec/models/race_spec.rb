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
require 'rails_helper'

RSpec.describe Race, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
