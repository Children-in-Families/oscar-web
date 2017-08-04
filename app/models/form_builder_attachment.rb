class FormBuilderAttachment < ActiveRecord::Base
  mount_uploaders :file, FormBuilderAttachmentUploader

  belongs_to :form_buildable, polymorphic: true

  validates :name, uniqueness: { scope: [:form_buildable_type, :form_buildable_id] }

  def self.file_by_name(value)
    find_by(name: value)
  end
end
