class ParticipationsController < ApplicationController
  before_action :set_race, only: [ :create ]

  def index
    @participations =
      Current.user.participations.finished.includes(:race).order(finished_at: :desc)
  end

  def create
    @participation = @race.participations.find_or_create_by!(user: Current.user)
    redirect_to @race
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
    # log the error somewhere
    redirect_to races_path, alert: "Failed to join race, try again!"
  end

  def update
    participation = Participation.find(params[:id])
    return unless participation && participation.race.in_progress?

    race = participation.race
    placement = calculate_placement(race: race)

    participation.update!(
      started_at: params[:started_at],
      finished_at: params[:finished_at],
      words_per_minute: params[:words_per_minute],
      placement: placement
    )

    unfinished_participations =
      race
        .participations
        .where(finished_at: nil)
        .where.not(id: participation.id)

    if unfinished_participations.empty?
      race.update!(status: :finished)
    end

    render json: { message: "Participation updated!" }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    # log the error somewhere
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def calculate_placement(race: race)
    race
      .participations
      .where.not(finished_at: nil)
      .count + 1
  end

  def set_race
    @race = Race.find(params[:race_id]) || Race.find_by(slug: params[:slug])
  end
end
