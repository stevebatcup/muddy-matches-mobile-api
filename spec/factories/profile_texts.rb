FactoryBot.define do
  factory :profile_text do
    profile
    status { 'approved' }
    type { 'activities_text' }
    content { 'lorem ipsum' }
    created { 1.month.ago }
    approved { 1.week.ago }
    timestamp { 1.week.ago }
    isEdited { 0 }
  end
end
