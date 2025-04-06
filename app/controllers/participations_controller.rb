class ParticipationsController < ApplicationController
  def create
    @race = Race.find(params[:race_id]) || Race.find_by(slug: params[:slug])

    @participation = @race.participations.find_or_create_by!(user: Current.user)
    redirect_to @race
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
    # log the error somewhere
    redirect_to races_path, alert: "Failed to join race, try again!"
  end
end
