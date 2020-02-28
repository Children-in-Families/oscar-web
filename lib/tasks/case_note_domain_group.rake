namespace :case_note_domain_group do
  desc "create domain group for case notes did not have domains"
  task create: :environment do
    Organization.switch_to 'mho'
    none_domain_case_notes = CaseNote.where.not(id: CaseNote.joins(:domain_groups).distinct.ids)
    none_domain_case_notes.map do |ndc|
      ndc.case_note_domain_groups.create!(domain_group_id: 1)
    end
  end

end
