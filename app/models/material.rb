class Material < ActiveRecord::Base
  validates :status, presence: true, uniqueness: true
end
