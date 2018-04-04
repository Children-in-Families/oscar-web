class CaseWorkerClient < ActiveRecord::Base
  belongs_to :client
  belongs_to :user
  belongs_to :enter_ngo

  has_paper_trail
end
