class FormBuilderAttachment < ActiveRecord::Base
  mount_uploaders :attachments, FormBuilderAttachmentUploader

   belongs_to :form_buildable, polymorphic: true
   accepts_nested_attributes_for :client_enrollment

   validates :name, uniqueness: { scope: [:form_buildable_type, :form_buildable_id] }
end
