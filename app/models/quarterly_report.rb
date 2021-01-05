class QuarterlyReport < ApplicationRecord
  belongs_to :case
  belongs_to :staff_information, class_name: 'User', foreign_key: 'staff_id'

  def kinship?
    self.case.case_type == 'KC' if self.case
  end

  def foster?
    self.case.case_type == 'FC' if self.case
  end
end
