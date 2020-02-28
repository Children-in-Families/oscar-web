class FieldSetting < ActiveRecord::Base
  validates :name, :group, :label, presence: true
end
