class ProfileText < ApplicationRecord
  self.table_name = 'profile_text'
  self.inheritance_column = :_type_disabled

  belongs_to :profile

  class << self
    def timestamp_attributes_for_create
      super << 'created'
    end

    def timestamp_attributes_for_update
      super << 'timestamp'
    end
  end
end
