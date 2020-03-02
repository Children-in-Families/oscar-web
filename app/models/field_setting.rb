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

  def self.hidden_group?(group_name)
    exists?(group: group_name, type: :group, visible: false)
  end

  private

  def assign_type
    self.type ||= 'type'
  end
end
