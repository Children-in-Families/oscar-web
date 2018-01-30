class FcImport
  def initialize
    Organization.switch_to 'cif'
    @clients = Client.joins(:cases).where(cases: { case_type: 'FC' }).uniq
    @program_stream = ProgramStream.find_by(name: 'Foster Care')
    @tracking = @program_stream.trackings.first
  end


  def fc_import
    @clients.each do |client|
      client.cases.fosters.order(:created_at).each do |foster_case|
        client_enrollment = client.client_enrollments.new(program_stream: @program_stream, enrollment_date: foster_case.start_date)
        if client_enrollment.valid?
          client_enrollment.save
          if (foster_case.support_amount.present? && foster_case.support_amount > 0) || foster_case.support_note.present?
            client_enrollment_tracking = client_enrollment.client_enrollment_trackings.new(tracking: @tracking)
            client_enrollment_tracking.properties['Date of Support Start'] = foster_case.start_date.to_s
            client_enrollment_tracking.properties['Total Support Amount'] = foster_case.support_amount.to_f.to_s
            client_enrollment_tracking.properties['Support Note'] = foster_case.support_note
            client_enrollment_tracking.save if client_enrollment_tracking.valid?
          end
        end

        if foster_case.exited?
          leave_program = LeaveProgram.new(program_stream: @program_stream, exit_date: foster_case.exit_date, client_enrollment: client_enrollment)
          exit_status = case foster_case.status
          when 'Exited - Dead'
            'Client died'
          when 'Exited - Age Out'
            'Client over 18'
          when 'Exited Independent'
            'Client financially independent'
          when 'Exited Adopted'
            'Client adopted by foster family'
          else
            'Other'
          end
          leave_program.properties['Reason for Ending FC Placement'] = exit_status
          leave_program.properties['Note on program exit'] = foster_case.exit_note
          leave_program.save(validate: false)
        end
      end
    end
  end
end
