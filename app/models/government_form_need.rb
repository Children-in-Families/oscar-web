class GovernmentFormNeed < ActiveRecord::Base
  has_paper_trail

  RANKS = [1, 2, 3, 4, 5, 6, 7, 8]

  belongs_to :government_form
  belongs_to :need

  default_scope { order(:created_at) }

  delegate :name, to: :need, prefix: true, allow_nil: true
end
