class FieldSetting < ActiveRecord::Base
  translates :label
  validates :name, :group, presence: true
end
