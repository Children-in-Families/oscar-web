class CustomFieldProperty < ActiveRecord::Base
  mount_uploaders :attachments, CustomFieldPropertyUploader

  belongs_to :custom_formable, polymorphic: true
  belongs_to :custom_field

  scope :by_custom_field, -> (value) { where(custom_field:  value) }
  scope :most_recents,    ->         { order('created_at desc') }

  has_paper_trail

  after_save :create_client_history, if: :client_form?

  validates :custom_field_id, presence: true

  validate do |obj|
    CustomFieldPresentValidator.new(obj).validate
    CustomFieldNumericalityValidator.new(obj).validate
    CustomFieldEmailValidator.new(obj).validate
  end

  private

  def client_form?
    custom_formable_type == 'Client'
  end

  def create_client_history
    ClientHistory.initial(self.custom_formable)
  end
end
