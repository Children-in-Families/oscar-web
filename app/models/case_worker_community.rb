class CaseWorkerCommunity < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :case_worker, class_name: 'User', foreign_key: :user_id
  belongs_to :community

  validates :case_worker, :community, presence: true
end
