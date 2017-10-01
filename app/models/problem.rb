class Problem < ActiveRecord::Base
  has_many :client_problems, dependent: :restrict_with_error
  has_many :clients, through: :client_problems
end
