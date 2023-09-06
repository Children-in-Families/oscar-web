class Setting < ActiveRecord::Base
  extend Enumerize
  include CacheHelper

  attr_accessor :organization_type

  has_paper_trail

  belongs_to :province
  belongs_to :district
  belongs_to :commune
  belongs_to :screening_assessment_form, class_name: 'CustomField'

  enumerize :assessment_score_order, in: ['random_order', 'ascending_order'], scope: true, predicates: true

  has_many :custom_assessment_settings

  accepts_nested_attributes_for :custom_assessment_settings, allow_destroy: true

  validates_numericality_of :max_assessment, only_integer: true, greater_than: 30, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'day' }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 4, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'week' }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 1, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'month' }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 0, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'year' }

  validates_numericality_of :max_case_note, only_integer: true, greater_than: 0, if: -> { max_case_note.present? }
  validates_numericality_of :age, only_integer: true, greater_than: 0, less_than_or_equal_to: 100, if: -> { age.present? }
  validates_numericality_of :custom_age, only_integer: true, greater_than: 0, less_than_or_equal_to: 100, if: -> { age.present? }

  validates :max_case_note, presence: true, if: -> { case_note_frequency.present? }
  validates :default_assessment, presence: true, if: -> { enable_default_assessment.present? }
  validates :max_assessment, presence: true, if: -> { enable_default_assessment.present? }
  validates :age, presence: true, if: -> { enable_default_assessment.present? }
  validates :assessment_frequency, presence: true, if: -> { enable_default_assessment.present? }
  validate  :custom_assessment_name, if: -> { enable_custom_assessment.present? }
  validates :custom_assessment_frequency, presence: true, if: -> { enable_custom_assessment.present? }
  validates :max_custom_assessment, presence: true, if: -> { enable_custom_assessment.present? }
  validates :custom_age, presence: true, if: -> { enable_custom_assessment.present? }
  validates :screening_assessment_form, presence: true, if: :use_screening_assessment?

  validates :delete_incomplete_after_period_unit, presence: true, inclusion: { in: %w(days weeks months) }, unless: :never_delete_incomplete_assessment?
  validates :delete_incomplete_after_period_value, presence: true, numericality: { only_integer: true, greater_than: 0 }, unless: :never_delete_incomplete_assessment?

  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true

  after_commit :flush_cache, :set_organization_type

  def delete_incomplete_after_period
    delete_incomplete_after_period_value.send(delete_incomplete_after_period_unit.to_sym)
  end

  def start_sharing_this_month(date_time)
    versions.where("to_char(created_at, 'YYYY-MM') = ?", date_time.to_date.strftime("%Y-%m")).map do |version|
      sharing_data = version.object_changes['sharing_data']

      sharing_data.is_a?(Array) ? sharing_data.last : sharing_data == true
    end
  end

  def stop_sharing_this_month(date_time)
    versions.where("to_char(created_at, 'YYYY-MM') = ?", date_time.to_date.strftime("%Y-%m")).map do |version|
      sharing_data = version.object_changes['sharing_data']

      sharing_data.is_a?(Array) ? sharing_data.last : sharing_data == false
    end
  end

  def current_sharing_with_research_module
    return [] unless sharing_data

    versions.order(created_at: :asc).map do |version|
      version.object_changes['sharing_data']
    end.compact
  end

  def max_assessment_duration
    max_assessment.send(assessment_frequency.to_sym)
  end

  def self.cache_first
    Rails.cache.fetch([Apartment::Tenant.current, 'current_setting']) { first }
  end

  private

  def custom_assessment_name
    errors.add(:custom_assessment, I18n.t('invalid_name')) if custom_assessment.downcase.include?('csi')
  end

  def set_organization_type
    return if organization_type.nil?

    org = Organization.current
    org.ngo_type = organization_type
    org.save
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'current_setting'])
    Rails.cache.fetch([Apartment::Tenant.current, 'table_name', 'settings'])
    assessment_either_overdue_or_due_today_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/assessment_either_overdue_or_due_today/].blank? }
    assessment_either_overdue_or_due_today_keys.each { |key| Rails.cache.delete(key) }
  end
end
