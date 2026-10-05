# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Plan.find_or_create_by!(name: "Starter") do |p|
  p.stripe_price_id = "price_1UMzYJEGIZlPZbHVDe7jM82G"
  p.amount_cents = 999
  p.interval = "month"
  p.active = true
end

Plan.find_or_create_by!(name: "Pro") do |p|
  p.stripe_price_id = "price_1UMzYYEGIZlPZbHVvcLhR6wO"
  p.amount_cents = 1999
  p.interval = "month"
  p.active = true
end
