class CaseWorkerFamily < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  belongs_to :case_worker, class_name: 'User', foreign_key: :user_id
  belongs_to :family

  validates :case_worker, :family, presence: true
end
