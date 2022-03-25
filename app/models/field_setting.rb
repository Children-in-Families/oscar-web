class FieldSetting < ActiveRecord::Base
  include CacheHelper
  self.inheritance_column = :_type_disabled

  translates :label
  validates :name, :group, presence: true

  default_scope -> { order(:created_at) }
  scope :without_hidden_fields, -> { where(visible: true) }

  before_save :assign_type
  after_commit :flush_cache

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

  def self.cache_all
    Rails.cache.fetch([Apartment::Tenant.current, 'field_settings']) { includes(:translations).to_a }
  end

  def cache_object
    Rails.cache.fetch([Apartment::Tenant.current, self.class.name, self.id]) { self }
  end

  def self.cache_by_name(name)
    Rails.cache.fetch([Apartment::Tenant::current, 'FieldSetting', name]) { find_by(name: name) }
  end

  private

  def assign_type
    self.type ||= 'field'
  end

  def flush_cache
    Rails.cache.delete(field_settings_cache_key)
  end
end
