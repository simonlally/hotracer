class RacesController < ApplicationController
  skip_before_action :require_authentication, only: [ :index ]
  before_action :set_race, only: [ :show, :start, :update ]

  def index
    @races = Race.joinable.includes(participations: :user)
  end

  def show
    @participations = @race.participations.includes(:user)
  end

  def create
    body = <<~BODY
      The quick brown fox jumps over the lazy dog.
      A journey of a thousand miles begins with a single step.
    BODY

    @race = Race.new(slug: SecureRandom.hex(10), body: body.squish, host: Current.user)

    if @race.save!
      @race.participations.create(user: Current.user)
      redirect_to @race
    else
      # handle error, show a flash message
    end
  end

  def start
    return unless params[:action] == "start"
    return unless @race.status == "pending"

    CountdownJob.perform_later(race_id: @race.id)
    head :ok
  end

  def update
    return unless @race.status == "in_progress"

    if @race.winner_id.nil?
      @race.update!(
        winner: Current.user,
        status: "finished"
      )

      render json: { message: "you won!" }, status: :ok
    end
  end

  private

  def set_race
    @race ||= Race.find(params[:id]) || Race.find_by(slug: params[:slug])
  end
end
