class ActionResult < ApplicationRecord

  has_paper_trail

  belongs_to :government_form
end
