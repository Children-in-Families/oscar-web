namespace :case_note_meeting_date_blank do
  desc "Update blank meeting date for Case Notes"
  task update: :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      ActiveRecord::Base.connection.execute("UPDATE case_notes SET meeting_date = created_at WHERE DATE(meeting_date) IS NULL")
    end
  end
end
