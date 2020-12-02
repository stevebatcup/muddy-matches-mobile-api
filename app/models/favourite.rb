class Favourite < ApplicationRecord
  self.primary_key = 'favourite_id'
  belongs_to :profile
  belongs_to :favourite_profile, class_name: 'Profile'

  validates_uniqueness_of :profile_id, scope: :favourite_profile_id, message: I18n.t('favourites.error.already_added')

  def delete_for_favouriter
    update_attribute(:favouriter_status, :deleted)
  end

  def delete_for_favourited
    update_attribute(:favourited_status, :deleted)
  end
end
