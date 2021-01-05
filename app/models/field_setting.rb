class FieldSetting < ApplicationRecord
  self.inheritance_column = :_type_disabled

  translates :label
  validates :name, :group, presence: true

  default_scope -> { order(:created_at) }

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

  def possible_key_match?(key_paths)
    key_paths.any? do |path|
      path == self.group ||
      path.to_s.pluralize == self.group.pluralize ||
      path == self.klass_name ||
      path.to_s.pluralize == self.klass_name.pluralize
    end
  end

  private

  def assign_type
    self.type ||= 'field'
  end
end
