class CustomFieldProperty < ActiveRecord::Base
  mount_uploaders :attachments, CustomFieldPropertyUploader

  belongs_to :custom_formable, polymorphic: true
  belongs_to :custom_field
  belongs_to :user

  has_many :form_builder_attachments, as: :form_buildable, dependent: :destroy

  scope :by_custom_field, -> (value) { where(custom_field:  value) }
  scope :most_recents,    ->         { order('created_at desc') }

  accepts_nested_attributes_for :form_builder_attachments, reject_if: proc { |attributes| attributes['name'].blank? &&  attributes['file'].blank? }

  has_paper_trail

  after_save :create_client_history, if: :client_form?

  validates :custom_field_id, presence: true

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'custom_field', 'fields').validate
    CustomFormNumericalityValidator.new(obj, 'custom_field', 'fields').validate
    CustomFormEmailValidator.new(obj, 'custom_field', 'fields').validate
  end

  def client_form?
    custom_formable_type == 'Client'
  end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end

  def self.properties_by(value)
    value = value.gsub("'", "''")
    field_properties = select("custom_field_properties.id, custom_field_properties.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  private

  def create_client_history
    ClientHistory.initial(custom_formable)
  end
end
