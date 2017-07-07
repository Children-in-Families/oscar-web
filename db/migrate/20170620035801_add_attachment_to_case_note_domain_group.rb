class AddAttachmentToCaseNoteDomainGroup < ActiveRecord::Migration
  def change
    add_column :case_note_domain_groups , :attachments, :string, array: true, default: []
  end
end
