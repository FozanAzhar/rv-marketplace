# Demo data for local testing and the landing page (GET /listings).
# Login as owner@example.com or hirer@example.com (password: password).
owner = User.find_or_create_by!(email: "owner@example.com") do |user|  user.name = "RV Owner"
  user.password = "password"
end

hirer = User.find_or_create_by!(email: "hirer@example.com") do |user|
  user.name = "RV Hirer"
  user.password = "password"
end

RvListing.find_or_create_by!(title: "Cozy Class C Camper", user: owner) do |listing|
  listing.description = "Perfect for weekend getaways with a full kitchen and sleeping for four."
  listing.location = "Byron Bay, NSW"
  listing.price_per_day = 120
end

RvListing.find_or_create_by!(title: "Luxury Motorhome", user: owner) do |listing|
  listing.description = "Spacious motorhome with slide-outs, solar panels, and premium amenities."
  listing.location = "Gold Coast, QLD"
  listing.price_per_day = 250
end

RvListing.find_or_create_by!(title: "Compact Travel Trailer", user: hirer) do |listing|
  listing.description = "Lightweight trailer ideal for couples exploring national parks."
  listing.location = "Cairns, QLD"
  listing.price_per_day = 85
end

puts "Seeded #{User.count} users and #{RvListing.count} listings"
