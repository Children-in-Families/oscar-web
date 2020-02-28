class FieldSetting < ActiveRecord::Base
  translates :label
  validates :name, :group, :label, presence: true
end
