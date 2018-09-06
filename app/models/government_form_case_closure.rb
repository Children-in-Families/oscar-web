class GovernmentFormCaseClosure < ActiveRecord::Base
  has_paper_trail

  belongs_to :government_form
  belongs_to :case_closure
end
