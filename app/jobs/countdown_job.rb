class CountdownJob < ApplicationJob
  queue_as :default

  def perform(race_id:)
    race = Race.find(race_id)
    return unless race.status == "pending"

    if race.update(status: "in_progress")
      Turbo::StreamsChannel.broadcast_update_to(
        race,
        target: "countdown",
        partial: "races/countdown",
        locals: { race: race }
      )
    end
  end
end
