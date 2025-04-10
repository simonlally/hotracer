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
require "rails_helper"

RSpec.describe Race, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      race = build(:race)

      expect(race).to be_valid
    end

    it "is invalid without a body" do
      race = build(:race, body: nil)

      expect(race).not_to be_valid
      expect(race.errors[:body]).to include("can't be blank")
    end

    it "is invalid without a slug" do
      race = build(:race, slug: nil)

      expect(race).not_to be_valid
      expect(race.errors[:slug]).to include("can't be blank")
    end

    it "is invalid without a status" do
      race = build(:race, status: nil)

      expect(race).not_to be_valid
      expect(race.errors[:status]).to include("can't be blank")
    end

    it "is invalid without a host" do
      race = build(:race, host: nil)

      expect(race).not_to be_valid
      expect(race.errors[:host]).to include("must exist")
    end
  end

  describe "associations" do
    it { should belong_to(:host).class_name("User") }
    it { should have_many(:participations) }
    it { should have_many(:users).through(:participations) }
  end

  describe "after_create_commit" do
    it "enqueues the NewRaceBroadcastJob after creation" do
      race = build(:race)

      expect { race.save }.to have_enqueued_job(NewRaceBroadcastJob)
    end
  end

  describe "after_update_commit" do
    it "broadcasts removal if the status is updated to 'in_progress'" do
      race = create(:race, status: "pending")

      expect(race).to receive(:broadcast_remove_race)
      race.update(status: "in_progress")
    end

    it "does not broadcast removal if the status is not 'in_progress'" do
      race = create(:race, status: "pending")

      expect(race).not_to receive(:broadcast_remove_race)
      race.update(status: "finished")
    end
  end

  describe "scopes" do
    describe ".joinable" do
      it "returns races with status 'pending'" do
        joinable_race = create(:race, status: "pending")
        non_joinable_race = create(:race, status: "in_progress")

        expect(Race.joinable).to include(joinable_race)
        expect(Race.joinable).not_to include(non_joinable_race)
      end
    end

    describe ".in_progress" do
      it "returns races with status 'in_progress'" do
        in_progress_race = create(:race, status: "in_progress")
        other_race = create(:race, status: "pending")

        expect(Race.in_progress).to include(in_progress_race)
        expect(Race.in_progress).not_to include(other_race)
      end
    end

    describe ".finished" do
      it "returns races with status 'finished'" do
        finished_race = create(:race, status: "finished")
        unfinished_race = create(:race, status: "in_progress")

        expect(Race.finished).to include(finished_race)
        expect(Race.finished).not_to include(unfinished_race)
      end
    end
  end


  describe "#finished?" do
    it "returns true if the race status is 'finished'" do
      race = build(:race, status: "finished")

      expect(race.finished?).to be true
    end

    it "returns false if the race status is not 'finished'" do
      race = build(:race, status: "in_progress")

      expect(race.finished?).to be false
    end
  end

  describe "#can_be_started?" do
    it "returns true if the user is the host and the race status is 'pending'" do
      host = create(:user)
      race = build(:race, host: host, status: "pending")

      expect(race.can_be_started?(host)).to be true
    end

    it "returns false if the user is not the host" do
      host = create(:user)
      other_user = create(:user)
      race = build(:race, host: host, status: "pending")

      expect(race.can_be_started?(other_user)).to be false
    end

    it "returns false if the race status is not 'pending'" do
      host = create(:user)
      race = build(:race, host: host, status: "in_progress")

      expect(race.can_be_started?(host)).to be false
    end
  end

  describe "#formatted_paragraph_body" do
    it "returns the body formatted with span tags and data attributes" do
      race = build(:race, body: "abc")
      formatted_body = race.formatted_paragraph_body

      expect(formatted_body).to eq(
        "<span data-race-target='formattedChar'>a</span>" \
        "<span data-race-target='formattedChar'>b</span>" \
        "<span data-race-target='formattedChar'>c</span>"
      )
    end
  end

  Race::VALID_STATUSES.each do |status|
    describe "##{status}?" do
      it "returns true when the status is '#{status}'" do
        race = build(:race, status:)

        expect(race.send("#{status}?")).to be true
      end
    end
  end
end
