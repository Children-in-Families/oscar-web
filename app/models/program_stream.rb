class ProgramStream < ActiveRecord::Base
  FORM_BUILDER_FIELDS = ['enrollment', 'exit_program'].freeze

  has_many   :domain_program_streams, dependent: :destroy
  has_many   :domains, through: :domain_program_streams
  has_many   :client_enrollments, dependent: :restrict_with_error
  has_many   :clients, through: :client_enrollments
  has_many   :trackings, dependent: :destroy
  has_many   :leave_programs

  has_paper_trail

  accepts_nested_attributes_for :trackings, allow_destroy: true

  validates :name, :rules, presence: true
  validates :name, uniqueness: true
  validate  :form_builder_field_uniqueness
  validate  :validate_remove_field, if: -> { id.present? }

  after_save :set_program_completed

  scope     :ordered,    -> { order(:name) }
  scope     :ordered_by, ->(column) { order(column) }
  scope     :completed,  -> { where(completed: true) }

  def self.enrollment_status_not_active(client)
    includes(:client_enrollments).where('client_enrollments.status != ? and client_enrollments.client_id = ?', 'Active', client.id).order('client_enrollments.status ASC', :name).uniq
  end

  def self.enrollment_status_active(client)
    includes(:client_enrollments).where('client_enrollments.status = ? and client_enrollments.client_id = ?', 'Active', client.id).order('client_enrollments.status ASC', :name).uniq
  end

  def self.without_status_by(client)
    ids = includes(:client_enrollments).where(client_enrollments: { client_id: client.id }).order('client_enrollments.status ASC', :name).uniq.collect(&:id)
    where.not(id: ids).order(:name)
  end

  def form_builder_field_uniqueness
    errors_massage = []
    FORM_BUILDER_FIELDS.each do |field|
      labels = []
      next unless send(field.to_sym).present?
      send(field.to_sym).map{ |obj| labels << obj['label'] }
      errors_massage << (errors.add field.to_sym, "Fields duplicated!") unless (labels.uniq.length == labels.length)
    end
    errors_massage
  end

  def validate_remove_field
    FORM_BUILDER_FIELDS.each do |field|
      next unless (send "#{ field }_changed?") && send(field).present?
      error_translation = I18n.t('cannot_remove_or_update')

      if field == 'enrollment'
        break unless enrollment_errors_message.present?
        errors.add(:enrollment, "#{enrollment_errors_message} #{error_translation}")
      elsif field == 'tracking'
        break unless tracking_errors_message.present?
        errors.add(:tracking, "#{tracking_errors_message} #{error_translation}")

      elsif field == 'exit_program'
        break unless exit_program_errors_message.present?
        errors.add(:exit_program, "#{exit_program_errors_message} #{error_translation}")
      end
    end
    errors
  end

  def last_enrollment
    client_enrollments.last
  end

  def number_available_for_client
    quantity - client_enrollments.active.size
  end

  def enroll?(client)
    enrollments = client_enrollments.enrollments_by(client)
    (enrollments.present? && enrollments.last.status == 'Exited') || enrollments.empty?
  end

  private

  def set_program_completed
    if enrollment.present? && exit_program.present? && trackings.present?
      update_columns(completed: true)
    else
      update_columns(completed: false)
    end
  end

  def enrollment_errors_message
    properties = client_enrollments.pluck(:properties).select(&:present?)
    error_fields(properties, enrollment_change).join(', ')
  end

  def tracking_errors_message
    properties = trackings.pluck(:properties).select(&:present?)
    error_fields(properties, tracking_change).join(', ')
  end

  def exit_program_errors_message
    properties = leave_programs.pluck(:properties).select(&:present?)
    error_fields(properties, exit_program_change).join(', ')
  end

  def error_fields(properties, column_change)
    error_fields = []
    properties.each do |property|
      field_remove = column_change.first - column_change.last
      field_remove.map{ |f| error_fields << f['label'] if property[f['label']].present? }
    end
    error_fields.uniq
  end
end
