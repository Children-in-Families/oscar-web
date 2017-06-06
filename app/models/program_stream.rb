class ProgramStream < ActiveRecord::Base
  enum frequencies: { day: 'Daily', week: 'Weekly', month: 'Monthly', year: 'Yearly' }
  FORM_BUILDER_FIELDS = ['enrollment', 'tracking', 'exit_program'].freeze

  has_many   :domain_program_streams, dependent: :destroy
  has_many   :domains, through: :domain_program_streams
  has_many   :client_enrollments, dependent: :restrict_with_error
  has_many   :clients, through: :client_enrollments
  has_many   :trackings
  has_many   :leave_programs

  validates :name, :rules, :enrollment, :tracking, :exit_program, presence: true
  validates :name, uniqueness: true
  validate  :form_builder_field_uniqueness
  validate  :validate_remove_field, if: -> { id.present? }
 
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
      next unless send "#{ field }_changed?" 
      column_change = send "#{ field }_change"
      error_fields = []

      if field == 'enrollment'
        client_enrollment_properties.each do |property|
          field_remove = column_change.first - column_change.last
          field_remove.map{ |f| error_fields << f['label'] if property[f['label']].present? }
        end
        break unless error_fields.present?
        error_message = "#{error_fields.join(', ')} #{I18n.t('cannot_remove_or_update')}"
        errors.add(:enrollment, "#{error_message} ")
      elsif field == 'tracking'
        tracking_properties.each do |property|
          field_remove = column_change.first - column_change.last
          field_remove.map{ |f| error_fields << f['label'] if property[f['label']].present? }
        end
        break unless error_fields.present?
        error_message = "#{error_fields.join(', ')} #{I18n.t('cannot_remove_or_update')}"
        errors.add(:tracking, "#{error_message} ")
      elsif field == 'exit_program'
        leave_program_properties.each do |property|
          field_remove = column_change.first - column_change.last
          field_remove.map{ |f| error_fields << f['label'] if property[f['label']].present? }
        end
        break unless error_fields.present?
        error_message = "#{error_fields.join(', ')} #{I18n.t('cannot_remove_or_update')}"
        errors.add(:exit_program, "#{error_message} ")
      end    
    end
    errors
  end

  def last_enrollment
    client_enrollments.last
  end

  private

  def client_enrollment_properties
    client_enrollments.pluck(:properties).select(&:present?)
  end

  def tracking_properties
    trackings.pluck(:properties).select(&:present?)
  end

  def leave_program_properties
    leave_programs.pluck(:properties).select(&:present?)
  end
end
