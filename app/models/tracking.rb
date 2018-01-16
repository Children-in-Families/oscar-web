class Tracking < ActiveRecord::Base
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

  def auto_update_trackings
    return unless self.fields_changed?
    labels_changed = []
    fields_was = self.fields_was
    fields_changed = self.fields_change.last
    tracking_fields_changed =  fields_changed - fields_was
    tracking_fields_changed.each do |tracking_field|
      fields_was.each do |field|
        labels_changed << [field['label'], tracking_field['label']] if field['name'] == tracking_field['name']
      end
    end
    self.client_enrollment_trackings.each do |client_enrollment_tracking|
      labels_changed.each do |label_old, label_new|
        client_enrollment_tracking.properties[label_new] = client_enrollment_tracking.properties.delete label_old
      end
      client_enrollment_tracking.save
    end
  end

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
end
