FactoryBot.define do
  factory :rv_listing do
    title { Faker::Vehicle.make_and_model }
    description { Faker::Lorem.paragraph }
    location { Faker::Address.city }
    price_per_day { Faker::Number.between(from: 50, to: 300) }
    user
  end
end
