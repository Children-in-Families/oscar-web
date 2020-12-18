class GlobalService < ApplicationRecord
  self.primary_key = "uuid"

  has_many :services, class_name: 'Service', foreign_key: 'uuid', dependent: :restrict_with_error
end
