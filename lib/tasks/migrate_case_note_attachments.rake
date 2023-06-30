namespace :case_note do
  desc 'Migrate attachment to case note'
  task migrate_attachments: :environment do
    Organization.without_shared.find_each do |org|
      Organization.switch_to(org.short_name)

      CaseNote.find_each do |case_note|
        CaseNoteAttachment.perform_async(case_note.id, org.short_name)
      end
    end
  end
end
