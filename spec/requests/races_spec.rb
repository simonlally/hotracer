require "rails_helper"

RSpec.describe "Races", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "GET /races" do
    it "returns a successful response" do
      get races_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /races/:id" do
    it "returns a successful response" do
      race = create(:race, host: user, body: "Mary had a little lamb.")
      create(:participation, user:, race:)

      get race_path(race)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /races" do
    it "creates a new race and participation for the host" do
      expect {
        post races_path
      }.to change(Race, :count).by(1)
       .and change(Participation, :count).by(1)

      expect(response).to redirect_to(race_path(Race.last))
    end
  end

  describe "POST /races/:id/start" do
    it "enqueues the countdown_job to start the race countdown process" do
      race = create(:race, host: user, body: "Mary had a little lamb.")
      create(:participation, user:, race:)

      expect {
        post start_race_path(race)
      }.to have_enqueued_job(CountdownJob)

      expect(response).to have_http_status(:success)
    end
  end
end
