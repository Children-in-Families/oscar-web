class AddAttachmentToCustomFieldProperty < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_field_properties, :attachments, :jsonb
  end
end
