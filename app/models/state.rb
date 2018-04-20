class State < ActiveRecord::Base
  has_many :townships
  has_many :clients, dependent: :restrict_with_error
end
