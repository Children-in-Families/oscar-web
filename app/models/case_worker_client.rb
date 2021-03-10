class CaseWorkerClient < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  belongs_to :user
  belongs_to :client
end
