FactoryBot.define do
  factory :message do
    content { Faker::Lorem.sentence }
    user
    rv_listing
  end
end
