class Enrollment < ActiveRecord::Base
  include EntityRetouch
  include NestedAttributesConcern
  include ClientEnrollmentTrackingConcern

  acts_as_paranoid without_default_scope: true

  belongs_to :programmable, polymorphic: true
  belongs_to :program_stream
  belongs_to :family, class_name: 'Family', foreign_key: 'programmable_id'

  has_many :enrollment_trackings, dependent: :destroy
  has_many :trackings, through: :enrollment_trackings
  has_one :leave_program, dependent: :destroy

  alias_attribute :new_date, :enrollment_date

  validates :enrollment_date, presence: true
  validate :enrollment_date_value, if: 'enrollment_date.present?'

  has_paper_trail

  scope :enrollments_by, -> (obj) { where(programmable_id: obj.id) }
  scope :find_by_program_stream_id, -> (value) { where(program_stream_id: value) }
  scope :active, -> { where(status: ['Active', 'active']) }
  scope :attached_with, -> (value) { where(programmable_type: value) }
  # may be used later in family grid
  scope :inactive, -> { where(status: 'Exited') }

  # may be used later in family book
  # delegate :name, to: :program_stream, prefix: true, allow_nil: true

  after_create :set_entity_status
  after_save :create_entity_enrollment_history
  after_destroy :reset_entity_status
  after_commit :flash_cache

  def active?
    status.downcase == 'active'
  end

  def has_enrollment_tracking?
    enrollment_trackings.present?
  end

  # may be used later in family grid
  def self.properties_by(value)
    value = value.gsub(/\'+/, "''")
    field_properties = select("enrollments.id, enrollments.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  # may be used later if family statistic advanced search (Quick Graph)
  # def short_enrollment_date
  #   enrollment_date.end_of_month.strftime '%b-%y'
  # end
  def self.cache_program_steams
    Rails.cache.fetch([Apartment::Tenant.current, 'Enrollment', 'cache_program_steams']) do
      program_ids = Enrollment.pluck(:program_stream_id).uniq
      ProgramStream.where(id: program_ids).order(:name).to_a
    end
  end

  private

  def set_entity_status
    entity_status = programmable_type == 'Family' ? 'Active' : 'active'
    programmable.update(status: entity_status)
  end

  def reset_entity_status
    return if programmable.enrollments.active.any?

    entity_status = programmable_type == 'Family' ? 'Accepted' : 'accepted'
    programmable.status = entity_status
    programmable.save(validate: false)
  end

  def create_entity_enrollment_history
    EntityEnrollmentHistory.initial(self)
  end

  def enrollment_date_value
    if leave_program.present? && leave_program.exit_date < enrollment_date
      errors.add(:enrollment_date, I18n.t('invalid_program_enrollment_date'))
    end
  end

  def flash_cache
    Rails.cache.delete([Apartment::Tenant.current, 'Enrollment', 'cache_program_steams'])
  end
end
