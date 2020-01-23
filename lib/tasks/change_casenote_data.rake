namespace :change_casenote_data do
  desc 'Faking case note data in development and staging'
  task :update, [:short_name] => :environment do |task, args|
    if Rails.env.development? || Rails.env.staging? || Rails.env.demo?
      Organization.switch_to args.short_name
      dummy_text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
      interaction_types = ['Visit', 'Non face to face', '3rd Party', 'Other']
      values = CaseNote.includes(:case_note_domain_groups).all.map do |case_note|
        case_note.attendee         = ['Father', 'Mother'].sample
        case_note.interaction_type = interaction_types.sample
        "(#{case_note.id}, '#{case_note.attendee}', '#{case_note.interaction_type}')"
      end.join(", ")

      sql = <<-SQL.squish
        UPDATE case_notes SET attendee = mapping_values.attendee, interaction_type = mapping_values.interaction_type FROM (VALUES #{values}) AS mapping_values (case_note_id, attendee, interaction_type) WHERE case_notes.id = mapping_values.case_note_id;
        UPDATE case_note_domain_groups SET note = '#{dummy_text}', attachments = ARRAY[]::varchar[];
      SQL
      ActiveRecord::Base.connection.execute(sql) if values.present?
      puts "Done updating case note!!!"
    end
  end
end
