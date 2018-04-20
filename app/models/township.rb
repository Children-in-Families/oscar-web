class Township < ActiveRecord::Base
  belongs_to :state
  has_many :clients, dependent: :restrict_with_error
end
