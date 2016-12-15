class AddFileToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :file, :string, default: ''
    add_reference :attachments, :progress_note, index: true, foreign_key: true
  end
end
