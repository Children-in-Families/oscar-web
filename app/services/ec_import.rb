class EcImport
  def initialize
    Organization.switch_to 'cif'
    @clients = Client.joins(:cases).where(cases: { case_type: 'EC' }).uniq
    @program_stream = ProgramStream.find_by('program_streams.name iLIKE ?', '%Emergency Care%')
    @tracking = @program_stream.trackings.first
  end


  def ec_import
    @clients.each do |client|
      client.cases.emergencies.order(:created_at).each do |emergency|
        client_enrollment = client.client_enrollments.new(program_stream: @program_stream, enrollment_date: emergency.start_date)
        client_enrollment.save(validate: false)
        if (emergency.support_amount.present? && emergency.support_amount > 0) || emergency.support_note.present?
          client_enrollment_tracking = client_enrollment.client_enrollment_trackings.new(tracking: @tracking)
          client_enrollment_tracking.properties['កាលបរិច្ឆេទឧបត្ថម្ភ / Date of Support Start'] = emergency.start_date.to_s
          client_enrollment_tracking.properties['ចំនួនឧបត្ថម្ភ / Total Support Amount'] = emergency.support_amount.to_f.to_s
          client_enrollment_tracking.properties['កំណត់ត្រាឧបត្ថម្ភ / Support Note'] = emergency.support_note
          client_enrollment_tracking.save(validate: false)
        end
        if emergency.exited?
          leave_program = LeaveProgram.new(program_stream: @program_stream, exit_date: emergency.exit_date, client_enrollment: client_enrollment)
          leave_program.properties['កំណត់ត្រាចាកចេញពីកម្មវិធី / Notes on Program Exit'] = emergency.exit_note
          leave_program.save(validate: false)
        end
      end
    end
  end
end
