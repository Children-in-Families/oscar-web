class ClientProblem < ActiveRecord::Base
  belongs_to :client
  belongs_to :problem
end
