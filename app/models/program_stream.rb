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

  validates :name, presence: true
  validates :name, uniqueness: true
  validate  :form_builder_field_uniqueness
  validate  :validate_remove_enrollment_field, if: -> { id.present? }

  after_save :set_program_completed

  scope  :ordered,     ->         { order('lower(name) ASC') }
  scope  :complete,    ->         { where(completed: true) }
  scope  :ordered_by,  ->(column) { order(column) }
  scope  :filter,      ->(value)  { where(id: value) }
  scope  :name_like,   ->(value)  { where(name: value) }

  def self.inactive_enrollments(client)
    joins(:client_enrollments).where("client_id = ? AND client_enrollments.created_at = (SELECT MAX(client_enrollments.created_at) FROM client_enrollments WHERE client_enrollments.program_stream_id = program_streams.id AND client_enrollments.client_id = #{client.id}) AND client_enrollments.status = 'Exited' ", client.id).ordered
  end

  def self.active_enrollments(client)
    joins(:client_enrollments).where("client_id = ? AND client_enrollments.created_at = (SELECT MAX(client_enrollments.created_at) FROM client_enrollments WHERE client_enrollments.program_stream_id = program_streams.id AND client_enrollments.client_id = #{client.id}) AND client_enrollments.status = 'Active' ", client.id).ordered
  end

  def self.without_status_by(client)
    ids = includes(:client_enrollments).where(client_enrollments: { client_id: client.id }).order('client_enrollments.status ASC', :name).uniq.collect(&:id)
    where.not(id: ids).ordered
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

  def validate_remove_enrollment_field
    return unless enrollment_changed?
    error_fields = []
    properties = client_enrollments.pluck(:properties).select(&:present?)
    properties.each do |property|
      field_remove = enrollment_change.first - enrollment_change.last
      field_remove.each do |field|
        label_name = property[field['label']]
        error_fields << field['label'] if label_name.present?
      end
    end
    return unless error_fields.present?
    error_message = "#{error_fields.uniq.join(', ')} #{I18n.t('cannot_remove_or_update')}"
    errors.add(:enrollment, "#{error_message}")
    errors.add(:tab, '3')
  end

  # def validate_remove_exit_program_field
  #   return unless exit_program_changed?
  #   error_fields = []
  #   properties = leave_programs.pluck(:properties).select(&:present?)
  #   properties.each do |property|
  #     field_remove = exit_program_change.first - exit_program_change.last
  #     field_remove.each do |field|
  #       label_name = property[field['label']]
  #       error_fields << field['label'] if label_name.present?
  #     end
  #   end
  #   return unless error_fields.present?
  #   error_message = "#{error_fields.uniq.join(', ')} #{I18n.t('cannot_remove_or_update')}"
  #   errors.add(:exit_program, "#{error_message}")
  #   errors.add(:tab, '5')
  # end

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

  def is_used?
    client_enrollments.active.present?
  end

  private

  def set_program_completed
    return update_columns(completed: false) if enrollment.empty? || exit_program.empty? || trackings.empty? || trackings.pluck(:name).include?('') || trackings.pluck(:fields).include?([])
    update_columns(completed: true)
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
