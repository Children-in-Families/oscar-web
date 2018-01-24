class Tracking < ActiveRecord::Base
  include UpdateFieldLabelsProgramStream
  FREQUENCIES = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze
  belongs_to :program_stream
  has_many :client_enrollment_trackings, dependent: :restrict_with_error
  has_many :client_enrollments, through: :client_enrollment_trackings

  has_paper_trail

  validates :name, uniqueness: { scope: :program_stream_id }

  validate :form_builder_field_uniqueness
  # validate :validate_remove_field, if: -> { id.present? }

  after_update :auto_update_trackings

  default_scope { order(:created_at) }

  def form_builder_field_uniqueness
    return unless fields.present?
    labels = []
    fields.map{ |obj| labels << obj['label'] if obj['label'] != 'Separation Line' && obj['type'] != 'paragraph' }
    (errors.add :fields, "Fields duplicated!") unless (labels.uniq.length == labels.length)
  end

  def validate_remove_field
    return unless fields_changed?
    error_translation = I18n.t('cannot_remove_or_update')
    error_fields = []
    properties = client_enrollment_trackings.pluck(:properties).select(&:present?)

    properties.each do |property|
      field_remove = fields_change.first - fields_change.last
      field_remove.map{ |f| error_fields << f['label'] if property[f['label']].present? }
    end

    return unless error_fields.present?
    errors.add(:fields, "#{error_fields.uniq.join(', ')} #{error_translation}")
    errors.add(:tab, 4)
  end

  def is_used?
    client_enrollment_trackings.present?
  end

  private

  def auto_update_trackings
    return unless self.fields_changed?
    labels_update(self.fields_change.last, self.fields_was, self.client_enrollment_trackings)
  end
end
