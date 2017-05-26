class Visit < ActiveRecord::Base
  belongs_to :user
  scope :find_user_login_per_month, -> { where(created_at: Date.today.beginning_of_month..Date.today.end_of_month) }
end
