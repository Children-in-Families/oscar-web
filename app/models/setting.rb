class Setting < ActiveRecord::Base
  extend Enumerize

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

  def delete_incomplete_after_period
    delete_incomplete_after_period_value.send(delete_incomplete_after_period_unit.to_sym)
  end

  def start_sharing_this_month(date_time)
    versions.where("to_char(created_at, 'YYYY-MM') = ?", date_time.to_date.strftime("%Y-%m")).map(&:object_changes).map{|a| YAML::load a}.select{|a| a['sharing_data']&.last == true }
  end

  def stop_sharing_this_month(date_time)
    versions.where("to_char(created_at, 'YYYY-MM') = ?", date_time.to_date.strftime("%Y-%m")).map(&:object_changes).map{|a| YAML::load a}.select{|a| a['sharing_data']&.last == false }
  end

  def current_sharing_with_research_module
    return [] unless sharing_data
    versions.order(created_at: :asc).map(&:object_changes).map{|a| YAML::load a}.select{|a| a['sharing_data'] }
  end

  def max_assessment_duration
    max_assessment.send(assessment_frequency.to_sym)
  end

  private

  def custom_assessment_name
    errors.add(:custom_assessment, I18n.t('invalid_name')) if custom_assessment.downcase.include?('csi')
  end
end
