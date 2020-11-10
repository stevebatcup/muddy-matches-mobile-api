FactoryBot.define do
  factory :profile do
    sequence :profile_id do |n|
      n
    end

    publish_status { :approved }
    visibility_status { :visible }
    created { 1.year.ago }
    stamp { 1.month.ago }
    profile_status { :approved }
    user { association :user, profile: instance }
    favourite_profiles { [] }
  end
end
