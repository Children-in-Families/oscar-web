class Tracking < ActiveRecord::Base
  include UpdateFieldLabelsFormBuilder
  FREQUENCIES = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze
  acts_as_paranoid

  belongs_to :program_stream
  has_many :client_enrollment_trackings, dependent: :restrict_with_error
  has_many :client_enrollments, through: :client_enrollment_trackings

  has_many :enrollment_trackings, dependent: :restrict_with_error
  has_many :enrollments, through: :enrollment_trackings

  has_paper_trail


  validate :form_builder_field_uniqueness
  validate :presence_of_label

  validates_as_paranoid
  validates :name, uniqueness: { scope: :program_stream_id }

  after_update :auto_update_trackings

  default_scope { order(:created_at) }

  delegate :name, to: :program_stream, prefix: true, allow_nil: true

  def form_builder_field_uniqueness
    return unless fields.present?
    labels = []
    fields.map{ |obj| labels << obj['label'] if obj['label'] != 'Separation Line' && obj['type'] != 'paragraph' }
    (errors.add :fields, "Fields duplicated!") unless (labels.uniq.length == labels.length)
  end

  def is_used?
    client_enrollment_trackings.present?
  end

  private

  def presence_of_label
    message = "Label " + I18n.t('cannot_be_blank')
    fields.each do |f|
      unless f['label'].present?
        errors.add(:fields, message)
        errors.add(:tab, 4)
        return
      end
    end
  end

  def auto_update_trackings
    return unless self.fields_changed?
    enrollment_tracking_objs = self.program_stream.attached_to_client? ? self.client_enrollment_trackings : self.enrollment_trackings
    labels_update(self.fields_change.last, self.fields_was, enrollment_tracking_objs)
  end
end
