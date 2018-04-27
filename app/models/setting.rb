class Setting < ActiveRecord::Base
  has_paper_trail
  # validates_numericality_of :min_assessment, only_integer: true, greater_than: 0, if: -> { min_assessment.present? }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 3, if: -> { max_assessment.present? && assessment_frequency == 'month' }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 0, if: -> { max_assessment.present? && assessment_frequency == 'year' }
  validates_numericality_of :max_case_note, only_integer: true, greater_than: 0, if: -> { max_case_note.present? }
  # validates_numericality_of :min_assessment, less_than: :max_assessment, if: -> { max_assessment.present? && min_assessment.present?}
  # validates_numericality_of :max_assessment, greater_than: :min_assessment, if: -> { max_assessment.present? && min_assessment.present?}
  validates :max_case_note, presence: true, if: -> { case_note_frequency.present? }
  # validates :min_assessment, :max_assessment, presence: true, if: -> { assessment_frequency.present? }
  validates :max_assessment, presence: true, if: -> { assessment_frequency.present? }

  before_update :modify_client_default_columns, if: -> { country_name_changed? && client_default_columns.any? }

  def modify_client_default_columns
    country = country_name_was
    case country
    when 'thailand'
      address = %w(plot_ road_ postal_code_ subdistrict_ district_ province_id_)
    when 'myanmar'
      address = %w(street_line1_ street_line2_ township_ state_)
    when 'lesotho'
      address = %w(suburb_ directions_ description_house_landmark_)
    when 'cambodia'
      address = %w(commune_ village_ street_number_ house_number_ district_ province_id_)
    end
    self.client_default_columns = client_default_columns - address
  end
end
