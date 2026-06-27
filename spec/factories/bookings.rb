FactoryBot.define do
  factory :booking do
    start_date { Date.current + 1.day }
    end_date { Date.current + 7.days }
    status { "pending" }
    user
    rv_listing
  end
end
