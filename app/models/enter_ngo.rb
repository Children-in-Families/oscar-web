class EnterNgo < ActiveRecord::Base
  belongs_to :client

  validates :accepted_date, presence: true
end
