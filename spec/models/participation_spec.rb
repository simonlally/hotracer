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
require "rails_helper"

RSpec.describe Participation, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      participation = build(:participation)

      expect(participation).to be_valid
    end

    it "is invalid without a user" do
      participation = build(:participation, user: nil)

      expect(participation).not_to be_valid
      expect(participation.errors[:user]).to include("must exist")
    end

    it "is invalid without a race" do
      participation = build(:participation, race: nil)

      expect(participation).not_to be_valid
      expect(participation.errors[:race]).to include("must exist")
    end
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:race) }
  end

  describe "callbacks" do
    it "broadcasts participation after create" do
      participation = build(:participation)
      expect(participation).to receive(:broadcast_participation)

      participation.save
    end

    it "broadcasts participation after update if placement changes" do
      participation = create(:participation)
      expect(participation).to receive(:broadcast_participation)

      participation.update(placement: 1)
    end

    it "does not broadcast if placement does not change" do
      participation = create(:participation, placement: 1)
      expect(participation).not_to receive(:broadcast_participation)

      participation.update(finished_at: Time.current)
    end
  end

  describe "scopes" do
    describe ".finished" do
      it "returns only finished participations" do
        finished_participation = create(:participation, finished_at: Time.current)
        unfinished_participation = create(:participation, finished_at: nil)

        expect(Participation.finished).to include(finished_participation)
        expect(Participation.finished).not_to include(unfinished_participation)
      end
    end
  end
end
