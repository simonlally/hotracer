class CountdownJob < ApplicationJob
  queue_as :default

  def perform(race_id:)
    race = Race.find(race_id)
    return unless race.status == "pending"

    race.update(status: "countdown")

    Turbo::StreamsChannel.broadcast_update_to(
      race,
      target: "countdown",
      html: "<div class='text-5xl font-bold text-yellow-500'>Get Ready!</div>"
    )

    sleep 1

    3.downto(1) do |i|
      Turbo::StreamsChannel.broadcast_update_to(
        race,
        target: "countdown",
        html: "<div class='text-5xl font-bold text-yellow-500'>#{i}</div>"
      )
      sleep 1
    end

    Turbo::StreamsChannel.broadcast_update_to(
      race,
      target: "countdown",
      html: "<div class='text-7xl font-bold text-green-600'>GO!</div>"
    )

    race.update(status: "in_progress", started_at: Time.current)
  end
end
