class ScreeningAssessment < ActiveRecord::Base
  mount_uploaders :attachments, ConsentFormUploader
  belongs_to :client

  has_many :developmental_marker_screening_assessments, dependent: :destroy
  has_many :developmental_markers, through: :developmental_marker_screening_assessments
  has_many :tasks, as: :taskable, dependent: :destroy, inverse_of: :taskable

  enum screening_type: { one_off: 'one_off', multiple: 'multiple' }
  validates :screening_assessment_date, :visitor, :client_milestone_age, presence: :true

  accepts_nested_attributes_for :developmental_marker_screening_assessments, allow_destroy: true
  accepts_nested_attributes_for :tasks, reject_if:  proc { |attributes| attributes['name'].blank? && attributes['expected_date'].blank? }, allow_destroy: true

  scope :multiple_screening_assessments, -> { where(screening_type: 'multiple') }

  def populate_developmental_markers(name = nil)
    DevelopmentalMarker.where.not(name: name).each do |developmental_marker|
      developmental_marker_screening_assessments.build(developmental_marker_id: developmental_marker.id)
    end
  end
end
