FactoryBot.define do
  factory :photo do
    profile
    user
    file { 'a-photo-file.png' }

    factory :main_approved_photo do
      status { 'approved' }
      photo_type { 'main' }
    end
  end
end
