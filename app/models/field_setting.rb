class FieldSetting < ActiveRecord::Base
  include CacheHelper
  self.inheritance_column = :_type_disabled

  translates :label, touch: true
  validates :name, :group, presence: true

  default_scope -> { order(:created_at) }
  scope :without_hidden_fields, -> { where(visible: true) }
  scope :by_instances, -> (ngo_short_name) { where('for_instances IS NULL OR for_instances iLIKE ?', "%#{ngo_short_name}%").includes(:translations).order(:group, :name) }

  before_save :assign_type
  after_commit :flush_cache

  def referee_info_tab?
    form_group_2 == 'referee_info_tab'
  end

  def client_info_tab?
    form_group_2 == 'client_info_tab'
  end

  def client_more_info_tab?
    form_group_2 == 'client_more_info_tab'
  end

  def protection_concern_tab?
    form_group_2 == 'protection_concern_tab'
  end

  def family_basic_info_tab?
    form_group_2 == 'basic_info_tab'
  end

  def family_member_tab?
    form_group_2 == 'family_member_tab'
  end

  def assessment_tab?
    form_group_2 == 'assessment'
  end

  def legal_documentations_tab?
    form_group_2 == 'legal_documentations'
  end

  def stakeholder_contacts_tab?
    form_group_2 == 'stakeholder_contacts'
  end

  def pickup_information_tab?
    form_group_2 == 'pickup_information'
  end

  def added_fields_by_ratanak?
    form_group_2 == 'added_field_by_ratanak'
  end

  def cmt_government_form_tab?
    form_group_2 == 'cmt_government_form'
  end

  def screening_form_tab?
    form_group_2 == 'screening_form'
  end

  def cmt_case_note_tab?
    form_group_2 == 'case_note'
  end

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

  def self.cache_by_name(field_name, group_name)
    Rails.cache.fetch([Apartment::Tenant::current, 'FieldSetting', field_name, group_name]) do
      find_by(name: field_name, group: group_name).try(:label)
    end
  end

  def self.cache_by_name_klass_name_instance(field_name, klass_name = 'client')
    Rails.cache.fetch([Apartment::Tenant.current, 'FieldSetting', 'klass_name', field_name, klass_name]) do
      find_by(name: field_name, klass_name: klass_name)
    end
  end

  def self.cache_query_find_by_ngo_name
    Rails.cache.fetch([Apartment::Tenant.current, 'field_settings', 'cache_query_find_by_ngo_name']) do
      by_instances(Apartment::Tenant.current).to_a
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

  def self.cache_legal_doc_fields
    Rails.cache.fetch([Apartment::Tenant.current, 'FieldSetting' 'gelal_dock_fields']) do
      fields = %w(national_id passport birth_cert family_book travel_doc letter_from_immigration_police ngo_partner mosavy dosavy msdhs complain local_consent warrant verdict screening_interview_form short_form_of_ocdm short_form_of_mosavy_dosavy detail_form_of_mosavy_dosavy short_form_of_judicial_police police_interview other_legal_doc)
      FieldSetting.without_hidden_fields.where(name: fields).pluck(:name)
    end
  end

  private

  def assign_type
    self.type ||= 'field'
  end

  def flush_cache
    puts "flushing cache for field_setting #{self.id}"

    Rails.cache.delete(field_settings_cache_key)
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, self.id])
    Rails.cache.delete([Apartment::Tenant::current, 'FieldSetting', self.name, self.group])
    Rails.cache.delete(field_settings_cache_key << 'cache_query_find_by_ngo_name')
    Rails.cache.delete([Apartment::Tenant.current, 'FieldSetting', 'klass_name', self.name, self.klass_name])
    Rails.cache.delete([Apartment::Tenant.current, 'field_settings', 'show_legal_doc'])
    Rails.cache.delete([Apartment::Tenant.current, 'table_name', 'field_settings'])
    Rails.cache.delete([Apartment::Tenant.current, 'FieldSetting', self.group, 'hidden_group'])
    Rails.cache.delete([Apartment::Tenant.current, 'FieldSetting', 'gelal_dock_fields'])
    Rails.cache.delete([Apartment::Tenant.current, 'field_settings', 'show_legal_doc', 'visible'])
  end
end
