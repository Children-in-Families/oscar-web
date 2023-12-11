class AddAttachmentsToCaseNote < ActiveRecord::Migration
  def change
    add_column :case_notes, :attachments, :string, array: true, default: []
  end
end
