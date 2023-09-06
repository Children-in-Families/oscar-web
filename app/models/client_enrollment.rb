class ClientEnrollment < ActiveRecord::Base
  include ClientRetouch
  include NestedAttributesConcern
  include ClientEnrollmentTrackingConcern

  acts_as_paranoid

  belongs_to :client
  belongs_to :program_stream

  has_many :client_enrollment_trackings, dependent: :destroy
  has_many :trackings, through: :client_enrollment_trackings
  has_one :leave_program, dependent: :destroy

  alias_attribute :new_date, :enrollment_date

  validates :enrollment_date, presence: true
  validate :enrollment_date_value, if: 'enrollment_date.present?'

  has_paper_trail

  scope :enrollments_by,              ->(client)         { where(client_id: client) }
  scope :find_by_program_stream_id,   ->(value)          { where(program_stream_id: value) }
  scope :active,                      ->                 { where(status: 'Active') }
  scope :inactive,                    ->                 { where(status: 'Exited') }

  delegate :name, to: :program_stream, prefix: true, allow_nil: true

  after_create :set_client_status
  after_save :create_client_enrollment_history
  after_destroy :reset_client_status
  after_save :flash_cache

  def active?
    status == 'Active'
  end

  def inactive?
    status == 'Exited'
  end

  def has_client_enrollment_tracking?
    client_enrollment_trackings.any?
  end

  def self.properties_by(value)
    value = value.gsub(/\'+/, "''")
    field_properties = select("client_enrollments.id, client_enrollments.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  def set_client_status
    client = Client.find self.client_id
    client.update(status: 'Active')
  end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end

  def reset_client_status
    client = Client.find(client_id)
    return if client.client_enrollments.active.any?
    
    client.status = 'Accepted'
    client.save(validate: false)
  end

  def short_enrollment_date
    enrollment_date.end_of_month.strftime '%b-%y'
  end

  def self.cache_active_program_options
    Rails.cache.fetch([Apartment::Tenant.current, 'cache_active_program_options']) do
      program_ids = ClientEnrollment.active.pluck(:program_stream_id).uniq
      ProgramStream.where(id: program_ids).order(:name).map { |ps| { ps.id.to_s => ps.name } }
    end
  end

  def self.cached_client_order_enrollment_date(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, object.class.name, "#{object.id}", 'ClientEnrollment', 'cached_client_order_enrollment_date', *fields_second]) do
      joins(:program_stream).where(program_streams: { name: fields_second }).order(enrollment_date: :desc).first.try(:enrollment_date)
    end
  end

  def self.cached_client_order_enrollment_date_properties(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, object.class.name, "#{object.id}", 'ClientEnrollment', 'cached_client_order_enrollment_date_properties', *fields_second]) do
      joins(:program_stream).where(program_streams: { name: fields_second }).order(enrollment_date: :desc).first.try(:properties)
    end
  end

  def self.cached_client_enrollment_date_join(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, object.class.name, "#{object.id}", 'cached_client_enrollment_date_join', *fields_second]) do
      joins(:program_stream).where(program_streams: { name: fields_second })
    end
  end

  private

  def create_client_enrollment_history
    ClientEnrollmentHistory.initial(self)
  end

  def enrollment_date_value
    if leave_program.present? && leave_program.exit_date < enrollment_date
      errors.add(:enrollment_date, I18n.t('invalid_program_enrollment_date'))
    end
  end

  def flash_cache
    Rails.cache.delete([Apartment::Tenant.current, 'cache_program_steam_by_enrollment'])
    Rails.cache.delete([Apartment::Tenant.current, 'cache_active_program_options'])
    cached_client_order_enrollment_date_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_order_enrollment_date/].blank? }
    cached_client_order_enrollment_date_keys.each { |key| Rails.cache.delete(key) }
    cached_client_order_enrollment_date_properties_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_order_enrollment_date_properties/].blank? }
    cached_client_order_enrollment_date_properties_keys.each { |key| Rails.cache.delete(key) }
    cached_client_enrollment_date_join_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_enrollment_date_join/].blank? }
    cached_client_enrollment_date_join_keys.each { |key| Rails.cache.delete(key) }
    Rails.cache.delete(["dashboard", "#{Apartment::Tenant.current}_client_errors"]) if enrollment_date_changed?

    cached_client_enrollment_properties_by_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_enrollment_properties_by/].blank? }
    cached_client_enrollment_properties_by_keys.each { |key| Rails.cache.delete(key) }
  end
end
