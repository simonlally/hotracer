# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "faker"

User.destroy_all

puts "Creating users, races and participation data..."

5.times do
  User.create!(
    email_address: Faker::Internet.unique.email,
    password: "password",
    password_confirmation: "password"
  )
end

5.times do
  Race.create!(
    body: Faker::Lorem.paragraph(sentence_count: 3),
    status: "finished",
    slug: SecureRandom.hex(10),
    host: User.all.sample
  )
end

Race.all.each do |race|
  rand(1..5).times do
    Participation.create!(
      user: User.all.sample,
      race: race,
      words_per_minute: rand(50..150),
      placement: rand(1..4),
      started_at: 4.minutes.ago,
      finished_at: 5.minutes.ago
    )
  end
end

test_users = [
  {
    email_address: "test@example.com",
    password: "test123"
  },
  {
    email_address: "test2@example.com",
    password: "test123"
  }
]

test_users.each do |user|
  User.find_or_create_by!(email_address: user[:email_address]) do |u|
    u.password = user[:password]
    u.password_confirmation = user[:password]
  end
  puts "Created test_user: #{user[:email_address]}"
end
