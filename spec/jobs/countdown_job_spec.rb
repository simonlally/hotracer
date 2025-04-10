require "rails_helper"

RSpec.describe CountdownJob, type: :job do
  describe "#perform" do
    it "raises an exception if the race cannot be found" do
      expect {
        described_class.perform_now(race_id: 35)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when the race is pending" do
      it "updates the race status to 'in_progress'" do
        race = create(:race, status: "pending")

        expect {
          described_class.perform_now(race_id: race.id)
        }.to change { race.reload.status }.from("pending").to("in_progress")
      end

      it "broadcasts the countdown update to the Turbo Streams channel" do
        race = create(:race)

        expect(Turbo::StreamsChannel).to receive(:broadcast_update_to).with(
          race,
          target: "countdown",
          partial: "races/countdown",
          locals: { race: race }
        )

        described_class.perform_now(race_id: race.id)
      end
    end

    context "when the race status is in_progress" do
      it "does not update the race status" do
        race = create(:race, status: "in_progress")

        expect {
          described_class.perform_now(race_id: race.id)
        }.not_to change { race.reload.status }
      end

      it "does not broadcast to the Turbo Streams channel" do
        race = create(:race, status: "in_progress")

        expect(Turbo::StreamsChannel).not_to receive(:broadcast_update_to)
        described_class.perform_now(race_id: race.id)
      end
    end
  end
end
