  module LeaveProgramHelper
    def leave_program_form_action_path
      if action_name.in?(%(new create))
        client_client_enrolled_program_leave_enrolled_programs_path(@client, @enrollment)
      else
        client_client_enrolled_program_leave_enrolled_program_path(@client, @enrollment, @leave_program)
      end
    end
  end
