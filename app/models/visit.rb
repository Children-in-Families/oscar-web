class Visit < ActiveRecord::Base
  has_paper_trail

  belongs_to :user

  scope :excludes_non_devs, -> { where(user_id: User.non_devs.ids) }
  scope :total_logins, -> (start_date, end_date) { where(created_at: start_date..end_date) }
end
