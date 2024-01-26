task remove_draft_case_note: :environment do |task, args|
  Organization.without_shared.each do |org|
    Apartment::Tenant.switch(org.short_name) do
      begin
        CaseNote.draft.each do |case_note|
          case_note.case_note_domain_groups.each do |case_note_domain_group|
            case_note_domain_group.tasks.destroy_all
            case_note_domain_group.destroy
          end

          case_note.destroy
        end
      rescue ActiveRecord::StatementInvalid => e
        puts "Error: #{e.message}"
        next if e.message.include?('UndefinedColumn')
      end
    end
  end
end
