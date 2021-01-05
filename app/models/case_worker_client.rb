class CaseWorkerClient < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :client
end
