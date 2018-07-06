class ClientTypeGovernmentForm < ActiveRecord::Base
  belongs_to :government_form
  belongs_to :client_type
end
