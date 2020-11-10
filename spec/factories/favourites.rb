FactoryBot.define do
  factory :favourite do
    profile_id { 1 }
    favourite_profile_id { 1 }
    created { 10.weeks.ago }
    viewed_on { nil }
    favouriter_status { :active }
    favourited_status { :active }
  end
end
