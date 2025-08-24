# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

leave_types = [
  "vacations",
  "medical",
  "academic",
  "maternity",
  "paternity"
]

states = [
  "pending",
  "approved",
  "rejected"
]

5.times do |i|
  start_date = Date.today + rand(1..30).days
  end_date = start_date + rand(1..14).days

  Leave.create!(
    start_date: start_date,
    end_date: end_date,
    leave_type: leave_types.sample,
    state: states.sample
  )
end

puts "Leaves created: #{Leave.count}"