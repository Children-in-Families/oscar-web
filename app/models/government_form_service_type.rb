class GovernmentFormServiceType < ActiveRecord::Base

  delegate :name, to: :service_type, prefix: true, allow_nil: true

  belongs_to :government_form
  belongs_to :service_type
end
