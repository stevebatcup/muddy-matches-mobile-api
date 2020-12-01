class Photo < ApplicationRecord
  self.table_name = 'profiles_photos'

  belongs_to :profile
  belongs_to :user

  class << self
    private

    def timestamp_attributes_for_create
      super << 'created'
    end
  end
end
