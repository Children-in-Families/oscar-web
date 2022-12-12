class IndexForeignKeysInFormBuilderAttachments < ActiveRecord::Migration[5.2]
  def change
    add_index :form_builder_attachments, :form_buildable_id unless index_exists? :form_builder_attachments, :form_buildable_id
  end
end
