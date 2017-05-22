class AddCustomFieldPropertyIdToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :custom_field_property_id, :integer
  end
end
