class GovernmentFormServiceType < ActiveRecord::Base
  has_paper_trail

  delegate :name, to: :service_type, prefix: true, allow_nil: true

  belongs_to :government_form
  belongs_to :service_type

  default_scope { order(:created_at) }
end
