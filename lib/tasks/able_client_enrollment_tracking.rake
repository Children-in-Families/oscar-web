namespace :able_client_enrollment_tracking do
  desc 'Enroll Able Clients to ABLE Program Stream'
  task :create, [:enrollment, :program_stream, :client] do |task, args|
    client         = args[:client]
    enrollment     = args[:enrollment];
    program_stream = args[:program_stream]
    progress_note_tracking      = program_stream.trackings.find_by(name: 'កត់សំគាល់ការរីកចំរើន Progress Note')
    equipment_material_tracking = program_stream.trackings.find_by(name: 'ស្ថានភាព  Equipment/Materials')
    client.progress_notes.each do |progress_note|
      pn_tracking = enrollment.client_enrollment_trackings.new(tracking: progress_note_tracking)

      pn_tracking.properties['កាលបរិច្ឆេទទស្សនា  Date of Visit'] = progress_note.date.to_s
      pn_tracking.properties['ឈ្មោះបុគ្គលិក  ABLE Staff Member'] = progress_note.user.name
      pn_tracking.properties['កន្លែង  Location'] = progress_note.location.try(:name)
      pn_tracking.properties['ព័ត៍មាន​នៃកន្លែងផ្សេង / Other - Details'] = progress_note.other_location
      pn_tracking.properties['ចំនុចដែលត្រូវធ្វើ  Interventions'] = progress_note.interventions.pluck(:action)
      pn_tracking.properties['សកម្មភាព/ការឆ្លើយតប  Activities/Response'] = progress_note.response
      pn_tracking.properties['ព័​ត៍​មាន​បន្ថែម  Additional Information'] = progress_note.additional_note

      if pn_tracking.valid?
        pn_tracking.save
        progress_note.attachments.each do |attachment|
          file = attachment.file.url
          att = pn_tracking.form_builder_attachments.new(name: 'ផ្ទុករូបថតឬព័ត៌មានផ្សេងទៀតឡើង  Upload photos or other info')
          att.remote_file_urls = [file]
          att.save
        end
      else
        open('tracking.log', 'a') do |e|
          e.puts DateTime.now
          e.puts "Enrollment ID : #{enrollment.id} - ProgressNote ID : #{progress_note.id} - Error : #{pn_tracking.errors.full_messages}"
        end
      end

      em_tracking = enrollment.client_enrollment_trackings.new(tracking: equipment_material_tracking)
      em_tracking.properties['ធាតុកាលបរិច្ឆេទដែលបានផ្តល់ឬប្រាក់កម្ចី  /  Date items given or loaned'] = progress_note.date
      em_tracking.properties['ស្ថានភាពបានឲ្យឬខឲ្យខ្ចី  Item given or loaned?'] = progress_note.material.try(:status)

      if em_tracking.valid?
        em_tracking.save
      else
        open('tracking.log', 'a') do |e|
          e.puts DateTime.now
          e.puts "Enrollment ID : #{enrollment.id} - ProgressNote ID : #{progress_note.id} - Error : #{em_tracking.errors.full_messages}"
        end
      end
    end
  end
end
