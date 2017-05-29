class AddAttachmentToCustomFieldProperty < ActiveRecord::Migration
  def change
    add_column :custom_field_properties, :attachments, :jsonb
  end
end
