class Department < ActiveRecord::Base
  has_many :users
  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
