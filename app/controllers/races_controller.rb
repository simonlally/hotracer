class RacesController < ApplicationController
  skip_before_action :require_authentication, only: [ :index ]
  def index
    @races = Race.joinable.includes(participations: :user)
  end

  def show
    @race = Race.find(params[:id]) || Race.find_by(slug: params[:slug])
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

  def update
  end
end
