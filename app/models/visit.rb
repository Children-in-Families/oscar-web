class Visit < ActiveRecord::Base
  has_paper_trail

  belongs_to :user

  scope :reportable, -> { where.not(user_id: User.oscar_or_dev.ids) }
  scope :excludes_non_devs, -> { where(user_id: User.non_devs.ids) }
  scope :total_logins, -> (start_date, end_date) { where(created_at: start_date..end_date) }
  scope :withtin, -> (date_range) { where(created_at: date_range) }
end
