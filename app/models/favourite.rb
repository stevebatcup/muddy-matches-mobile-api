class Favourite < ApplicationRecord
  belongs_to :profile
  belongs_to :favourite_profile, class_name: 'Profile'

  validates_uniqueness_of :profile_id, scope: :favourite_profile_id

  def delete_for_favouriter
    update_attribute(:favouriter_status, :deleted)
  end

  def delete_for_favourited
    update_attribute(:favourited_status, :deleted)
  end
end
