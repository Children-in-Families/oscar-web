class FieldSetting < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  translates :label
  validates :name, :group, presence: true

  before_save :assign_type

  def field_setting?
    type == 'field'
  end

  def group_setting?
    type == 'group'
  end

  private

  def assign_type
    self.type ||= 'type'
  end
end
