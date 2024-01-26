class AddAttachmentsToReleaseNotes < ActiveRecord::Migration
  def change
    add_column :release_notes, :attachments, :text, array: true, default: []
  end
end
