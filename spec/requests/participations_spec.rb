require "rails_helper"

RSpec.describe "Participations", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "GET /participations" do
    it "returns a successful response" do
      get participations_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /participations" do
    it "creates a new participation" do
      race = create(:race, host: user, body: "Mary had a little lamb.")

      expect {
        post participations_path, params: { race_id: race.id }
      }.to change(Participation, :count).by(1)

      expect(response).to redirect_to(race)
    end
  end

  describe "PATCH /participations/:id" do
    it "updates an existing participation with racing results" do
      race = create(
        :race,
        host: user,
        body: "Mary had a little lamb.",
        status: "in_progress"
      )

      participation = create(
        :participation,
        user: user,
        race: race
      )

      params = {
        started_at: Time.current - 1.minute,
        finished_at: Time.current,
        words_per_minute: 75
      }

      patch participation_path(participation), params: params

      expect(response).to have_http_status(:success)
      expect(participation.reload.words_per_minute).to eq(75)
    end

    it "finishes race if all participants have completed" do
      race = create(
        :race,
        host: user,
        body: "Mary had a little lamb.",
        status: "in_progress"
      )

      create(
        :participation,
        user: user,
        race: race,
        started_at: Time.current - 1.minute,
        finished_at: 30.seconds.ago,
        words_per_minute: 99,
        placement: 1
      )

      second_participation = create(
        :participation,
        user: create(:user),
        race: race
      )

      params = {
        started_at: Time.current - 1.minute,
        finished_at: Time.current,
        words_per_minute: 75
      }

      patch participation_path(second_participation), params: params

      expect(response).to have_http_status(:success)
      expect(race.reload.status).to eq("finished")
    end
  end
end
