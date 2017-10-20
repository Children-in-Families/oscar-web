namespace :able_client_enrollment do
  desc 'Enroll Able Clients to ABLE Program Stream'
  task create: :environment do |task, args|
    org = Organization.find_by(short_name: 'cif')
    Organization.switch_to(org.short_name)

    program_stream = ProgramStream.find_by(name: 'ABLE')
    client_ids     = ProgressNote.pluck(:client_id).uniq
    clients        = Client.where(id: client_ids)
    clients.each do |client|
      enrollment_date = client.progress_notes.order(:date).first.date
      enrollment      = client.client_enrollments.find_or_initialize_by(program_stream: program_stream, enrollment_date: enrollment_date)

      next if enrollment.persisted?
      if enrollment.valid?
        enrollment.save
        Rake::Task['able_client_enrollment_tracking:create'].invoke(enrollment, program_stream, client)
        Rake::Task['able_client_enrollment_tracking:create'].reenable
      else
        open('enrollment.log', 'a') do |e|
          e.puts DateTime.now
          e.puts "Client ID : #{client.id} - Error : #{enrollment.errors.full_messages}"
        end
      end
    end
  end
end
