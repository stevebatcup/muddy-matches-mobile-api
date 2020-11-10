class Favourite < ApplicationRecord
  belongs_to :profile
  belongs_to :favourite_profile, class_name: 'Profile'
end
