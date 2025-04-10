require "rails_helper"

RSpec.describe NewRaceBroadcastJob, type: :job do
  describe "#perform" do
    it "broadcasts the new race to the Turbo Streams channel" do
      race = create(:race)

      expect(Turbo::StreamsChannel).to receive(:broadcast_append_to).with(
        "races",
        target: "races",
        partial: "races/race",
        locals: { race: race }
      )

      described_class.perform_now(race_id: race.id)
    end

    it "raises an exception if the race cannot be found" do
      expect {
        described_class.perform_now(race_id: 35)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
