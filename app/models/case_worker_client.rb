class CaseWorkerClient < ActiveRecord::Base
  belongs_to :client
  belongs_to :user

  has_paper_trail
end
