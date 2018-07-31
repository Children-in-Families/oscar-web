class GovernmentFormProblem < ActiveRecord::Base
  has_paper_trail

  RANKS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]

  delegate :name, to: :problem, prefix: true, allow_nil: true

  default_scope { order(:created_at) }

  belongs_to :government_form
  belongs_to :problem
end
