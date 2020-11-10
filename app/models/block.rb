class Block < ApplicationRecord
  self.table_name = 'blocked'
  self.primary_key = 'block_id'

  belongs_to :profile
  belongs_to :blocked_profile, class_name: 'Profile'
end
