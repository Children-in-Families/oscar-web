class CaseWorkerTask < ActiveRecord::Base
  belongs_to :task
  belongs_to :user

  has_paper_trail
end
