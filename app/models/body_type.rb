class BodyType < ApplicationRecord
  self.table_name = 'ref_body_types'

  has_many :profiles
end
