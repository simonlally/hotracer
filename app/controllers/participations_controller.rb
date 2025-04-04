class ParticipationsController < ApplicationController
  def create
    @race = Race.find(params[:race_id]) || Race.find_by(slug: params[:slug])

    @participation = @race.participations.new(user: Current.user)
    if @participation.save
      redirect_to @race
    end
  end
end
