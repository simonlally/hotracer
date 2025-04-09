class NewRaceBroadcastJob < ApplicationJob
  queue_as :default

  def perform(race_id:)
    race = Race.find(race_id)

    Turbo::StreamsChannel.broadcast_append_to(
      "races",
      target: "races",
      partial: "races/race",
      locals: { race: race }
    )
  end
end
