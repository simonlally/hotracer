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
      Lorem ipsum dolor sit amet, consectetur adipiscing elit.#{' '}
      Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
      Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.#{' '}
      Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,#{' '}
      sunt in culpa qui officia deserunt mollit anim id est laborum.
    BODY

    @race = Race.new(slug: SecureRandom.hex(10), body: body, host: Current.user)

    if @race.save!
      @race.participations.create(user: Current.user)
      redirect_to @race
    else
      # uh oh
    end
  end

  def start
    return unless params[:action] == "start"
    return unless @race.status == "pending"

    CountdownJob.perform_later(race_id: @race.id)
    head :ok
  end

  def update
  end

  private

  def set_race
    @race ||= Race.find(params[:id]) || Race.find_by(slug: params[:slug])
  end
end
