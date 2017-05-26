class Visit < ActiveRecord::Base
  belongs_to :user

  def self.previous_month_logins
    beginning_of_month = 1.month.ago.beginning_of_month
    end_of_month       = 1.month.ago.end_of_month
    where(created_at: beginning_of_month..end_of_month)
  end
end
