FactoryBot.define do
  factory :profile do
    sequence :profile_id do |n|
      n
    end

    factory :approved_profile do
      publish_status { :approved }
      profile_status { :approved }
    end

    visibility_status { :visible }
    created { 1.year.ago }
    stamp { 1.month.ago }
    user { association :user, profile: instance }
    favourite_profiles { [] }
    gender { 'female' }
    dating_looking_for { 'male' }
    dating { 'yes' }
  end
end
