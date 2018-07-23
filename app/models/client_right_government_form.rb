class ClientRightGovernmentForm < ActiveRecord::Base
  has_paper_trail
  delegate :name, to: :client_right, prefix: true, allow_nil: true

  belongs_to :government_form
  belongs_to :client_right

  default_scope { order(:created_at) }
end
