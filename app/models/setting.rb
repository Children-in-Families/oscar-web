class Setting < ActiveRecord::Base
  validates_numericality_of :min_assessment, :max_assessment, :max_case_note, only_integer: true, greater_than: 0
end

