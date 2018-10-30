namespace :change_casenote_data do
  desc 'Faking case note data in development and staging'
  task update: :environment do |task, args|
    if Rails.env.development? || Rails.env.staging?
      Organization.all.each do |org|
        next if org.short_name == 'shared'
        Organization.switch_to org.short_name
        dummy_text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        interaction_types = ['Visit', 'Non face to face', '3rd Party', 'Other']
        CaseNote.includes(:case_note_domain_groups).all.each do |case_note|
          case_note.attendee         = ['Father', 'Mother'].sample
          case_note.interaction_type = interaction_types.sample
          case_note.case_note_domain_groups.each do |domain|
            domain.note = dummy_text
            domain.attachments = []
            domain.save(validate: false)
          end
          case_note.save(validate: false)
        end
      end

      puts "Done updating case note!!!"
    end
  end
end
