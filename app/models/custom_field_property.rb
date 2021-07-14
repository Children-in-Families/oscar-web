class CustomFieldProperty < ActiveRecord::Base
  include NestedAttributesConcern
  include ClientEnrollmentTrackingConcern

  mount_uploaders :attachments, CustomFieldPropertyUploader

  belongs_to :custom_formable, polymorphic: true
  belongs_to :custom_field
  belongs_to :user

  scope :by_custom_field, -> (value) { where(custom_field:  value) }
  scope :most_recents,    ->         { order('created_at desc') }

  has_paper_trail

  after_save :create_client_history, if: :client_form?

  validates :custom_field_id, presence: true

  def client_form?
    custom_formable_type == 'Client'
  end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end

  def self.properties_by(value)
    value = value.gsub(/\'+/, "''")
    field_properties = select("custom_field_properties.id, custom_field_properties.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  def is_editable?
    setting = Setting.first
    max_duration = setting.try(:custom_field_limit).zero? ? 2 : setting.try(:custom_field_limit)
    custom_field_frequency = setting.try(:custom_field_frequency)
    created_at >= max_duration.send(custom_field_frequency).ago
  end

  private

  def create_client_history
    ClientHistory.initial(custom_formable)
  end
end
