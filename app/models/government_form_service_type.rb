class GovernmentFormServiceType < ActiveRecord::Base
  belongs_to :government_form
  belongs_to :service_type
end
