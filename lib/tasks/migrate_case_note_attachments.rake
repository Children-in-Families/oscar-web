name :case_note do
  desc 'Migrate attachment to case note' do
    task migrate_attachments: :environment do
      Organization.find_each do |org|
        Organization.switch_to(org.short_name)

        CaseNote.find_each do |case_note|
          attachments = case_note.case_note_domain_groups.map(&:attachments).flatten
          case_note.attachments = attachments
          case_note.save(validate: false)
        end
      end
    end
  end
end
