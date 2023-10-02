class LeaveProgram < ActiveRecord::Base
  include NestedAttributesConcern
  include ClientEnrollmentTrackingConcern

  acts_as_paranoid without_default_scope: true

  belongs_to :enrollment
  belongs_to :client_enrollment
  belongs_to :program_stream

  alias_attribute :new_date, :exit_date

  validates :exit_date, presence: true
  validate :exit_date_value, if: 'exit_date.present?'

  after_save :create_leave_program_history
  after_create :update_enrollment_status, :set_entity_status
  after_commit :flush_cache

  has_paper_trail

  scope :find_by_program_stream_id, -> (value) { where(program_stream_id: value) }

  # validate do |obj|
  #   CustomFormPresentValidator.new(obj, 'program_stream', 'exit_program').validate
  #   CustomFormNumericalityValidator.new(obj, 'program_stream', 'exit_program').validate
  #   CustomFormEmailValidator.new(obj, 'program_stream', 'exit_program').validate
  # end

  def self.properties_by(value)
    value = value.gsub(/\'+/, "''")
    field_properties = select("leave_programs.id, leave_programs.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  def update_enrollment_status
    enrollment_obj = self.enrollment_id ? self.enrollment : self.client_enrollment
    enrollment_obj.update_columns(status: 'Exited')
  end

  def set_entity_status
    if self.enrollment_id
      entity = self.enrollment.programmable
      if entity.enrollments.active.empty?
        entity_status = self.enrollment.programmable_type == 'Family' ? 'Accepted' : 'accepted'
        entity.status = entity_status
        entity.save(validate: false)
      end
    else
      client = Client.find(self.client_enrollment.client_id)
      if client.client_enrollments.active.empty?
        client.status = 'Accepted'
        client.save(validate: false)
      end
    end
  end

  def self.cached_program_exit_date(fields_second, ids)
    Rails.cache.fetch([Apartment::Tenant.current, 'LeaveProgram', 'cached_program_exit_date', *fields_second, *ids.sort]) {
      joins(:program_stream).where(program_streams: { name: fields_second }, leave_programs: { client_enrollment_id: ids }).order(exit_date: :desc).first.try(:exit_date)
    }
  end

  def self.cached_program_stream_leave(fields_second, ids)
    Rails.cache.fetch([Apartment::Tenant.current, 'LeaveProgram', 'cached_program_stream_leave', *fields_second, *ids.sort]) {
      joins(:program_stream).where(program_streams: { name: fields_second }, leave_programs: { client_enrollment_id: ids })
    }
  end

  private

  def create_leave_program_history
    LeaveProgramHistory.initial(self)
  end

  def exit_date_value
    enrollment_exit_date = enrollment_id ? enrollment.enrollment_date : client_enrollment.enrollment_date
    if exit_date < enrollment_exit_date
      errors.add(:exit_date, I18n.t('invalid_program_exit_date'))
    end
  end

  def flush_cache
    cached_program_exit_date_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_program_exit_date/].blank? }
    cached_program_exit_date_keys.each { |key| Rails.cache.delete(key) }
    cached_program_exit_date_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_program_stream_leave/].blank? }
    cached_program_exit_date_keys.each { |key| Rails.cache.delete(key) }
  end
end
