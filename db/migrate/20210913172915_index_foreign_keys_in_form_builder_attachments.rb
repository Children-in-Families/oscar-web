class IndexForeignKeysInFormBuilderAttachments < ActiveRecord::Migration
  def change
    add_index :form_builder_attachments, :form_buildable_id
  end
end
