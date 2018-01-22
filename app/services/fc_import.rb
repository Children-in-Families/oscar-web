class FcImport
  def initialize
    Organization.switch_to 'cif'
    @clients = Client.joins(:cases).where(cases: { case_type: 'FC' }).uniq
    @program_stream = ProgramStream.find_by(name: 'Foster Care')
    @tracking = @program_stream.trackings.first
  end


  def fc_import
    @clients.each do |client|
      case_fc = client.cases.fosters.current.nil? ? client.cases.fosters.last : client.cases.fosters.current
      client_enrollment = client.client_enrollments.new(program_stream: @program_stream, enrollment_date: case_fc.start_date)
      # client_enrollment.properties['អង្គការដៃគូកំពុងជួយបច្ចុប្បន្ន / Ongoing Partner'] = case_fc.partner.try(:name)
      # client_enrollment.properties['Ongoing Partner Key Contact'] = case_fc.partner.try(:carer_names)
      # client_enrollment.properties['Ongoing Partner Phone Number'] = case_fc.partner.try(:contact_person_mobile)
      if client_enrollment.valid?
        client_enrollment.save
        client_enrollment_tracking = client_enrollment.client_enrollment_trackings.new(tracking: @tracking)
        client_enrollment_tracking.properties['Date of Support Start'] = case_fc.start_date.to_s
        client_enrollment_tracking.properties['Total Support Amount'] = case_fc.support_amount.nil? ? '0.0' : case_fc.support_amount.to_s
        client_enrollment_tracking.properties['Support Note'] = case_fc.support_note
        client_enrollment_tracking.save if client_enrollment_tracking.valid?
      end

      if case_fc.exited?
        leave_program = LeaveProgram.new(program_stream: @program_stream, exit_date: case_fc.exit_date, client_enrollment: client_enrollment)
        exit_status = case case_fc.status
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
        leave_program.properties['Note on program exit'] = case_fc.exit_note
        leave_program.save(validate: false)
      end
    end
  end
end
