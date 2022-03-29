class FieldSetting < ActiveRecord::Base
  include CacheHelper
  self.inheritance_column = :_type_disabled

  translates :label
  validates :name, :group, presence: true

  default_scope -> { order(:created_at) }
  scope :without_hidden_fields, -> { where(visible: true) }
  scope :by_instances, ->(ngo_short_name) { where('for_instances IS NULL OR for_instances iLIKE ?', "%#{ngo_short_name}%").includes(:translations).order(:group, :name) }

  before_save :assign_type
  after_commit :flush_cache

  def field_setting?
    type == 'field'
  end

  def group_setting?
    type == 'group'
  end

  def self.hidden_group?(group_name)
    Rails.cache.fetch([Apartment::Tenant.current, 'field_settings', group_name, 'hidden_group']) do
      exists?(group: group_name, type: :group, visible: false)
    end
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
    Rails.cache.fetch([Apartment::Tenant::current, 'FieldSetting', name]) do
      find_by(name: name)
    end
  end

  def self.cache_by_name_klass_name_instance(name, klass_name = 'client')
    Rails.cache.fetch([Apartment::Tenant.current, 'FieldSetting', name, klass_name]) do
      find_by(name: name, klass_name: klass_name)
    end
  end

  def self.cache_query_find_by_ngo_name
    Rails.cache.fetch([Apartment::Tenant.current, 'field_settings', 'cache_query_find_by_ngo_name']) do
      by_instances(Apartment::Tenant.current)
    end
  end

  def self.show_legal_doc(fields)
    Rails.cache.fetch([Apartment::Tenant.current, 'field_settings', 'show_legal_doc']) do
      by_instances(Apartment::Tenant.current).where(name: fields).any?
    end
  end

  def self.show_legal_doc_visible(fields)
    Rails.cache.fetch([Apartment::Tenant.current, 'field_settings', 'show_legal_doc', 'visible']) do
      by_instances(Apartment::Tenant.current).where(visible: true, name: fields).any?
    end
  end

  private

  def assign_type
    self.type ||= 'field'
  end

  def flush_cache
    Rails.cache.delete(field_settings_cache_key)
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, self.id])
    Rails.cache.delete([Apartment::Tenant::current, 'FieldSetting', self.name])
    Rails.cache.delete(field_settings_cache_key << 'cache_query_find_by_ngo_name')
    Rails.cache.delete([Apartment::Tenant.current, 'FieldSetting', self.name, self.klass_name])
    Rails.cache.delete([Apartment::Tenant.current, 'field_settings', 'show_legal_doc'])
    Rails.cache.delete([Apartment::Tenant.current, 'table_name', 'field_settings'])
    Rails.cache.delete([Apartment::Tenant.current, 'FieldSetting', self.group_name, 'hidden_group'])
  end
end
