class CaseWorkerClient < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid double_tap_destroys_fully: false

  belongs_to :user
  belongs_to :client
end
