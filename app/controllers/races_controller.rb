class RacesController < ApplicationController
  allow_unauthenticated_access only: [ :index ]
  before_action :set_race, only: [ :show, :start ]

  def index
    @races = Race.joinable.includes(participations: :user)
  end

  def show
    @participations = @race.participations.includes(:user)
    @current_participation = @race.participations.find_by(user: Current.user)
  end

  def create
    body = <<~BODY
      The quick brown fox jumps over the lazy dog.
      A journey of a thousand miles begins with a single step.
    BODY

    @race = Race.new(slug: SecureRandom.hex(10), body: body.squish, host: Current.user)
    participation = @race.participations.build(user: Current.user)

    begin
      redirect_to @race if @race.save! && participation.save!
    rescue ActiveRecord::RecordInvalid => e
      # log the error somewhere
      redirect_to :index, notice: "Something went wrong creating a new race, try again!"
    end
  end

  def start
    return unless @race.status == "pending"

    CountdownJob.perform_later(race_id: @race.id)
    head :ok
  end

  private

  def set_race
    @race ||= Race.find(params[:id]) || Race.find_by(slug: params[:slug])
  end
end
