class ClientTypeGovernmentForm < ActiveRecord::Base
  has_paper_trail

  belongs_to :government_form
  belongs_to :client_type
end
