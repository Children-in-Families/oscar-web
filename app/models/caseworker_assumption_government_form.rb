class CaseworkerAssumptionGovernmentForm < ActiveRecord::Base
  has_paper_trail

  delegate :name, to: :caseworker_assumption, prefix: true, allow_nil: true

  belongs_to :government_form
  belongs_to :caseworker_assumption
end
