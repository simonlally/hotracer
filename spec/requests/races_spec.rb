require "rails_helper"

RSpec.describe "Races", type: :request do
  let(:user) { create(:user) }

  context "with a sign in user" do
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

  context "without a sign in user" do
    describe "GET /races/:id" do
      it "redirects to the sign-in page" do
        race = create(:race, host: user, body: "Mary had a little lamb.")
        get race_path(race)

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "POST /races" do
      it "does not create a new race and redirects to the sign-in page" do
        expect {
          post races_path
        }.not_to change(Race, :count)

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "POST /races/:id/start" do
      it "does not enqueue the countdown job and redirects to the sign-in page" do
        race = create(:race, host: user, body: "Mary had a little lamb.")

        expect {
          post start_race_path(race)
        }.not_to have_enqueued_job(CountdownJob)

        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
