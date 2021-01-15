  module LeaveProgramHelper
    def leave_program_form_action_path
      if action_name.in?(%(new create))
        if params[:family_id]
          family_enrolled_program_leave_enrolled_programs_path(@entity, @enrollment)
        elsif params[:community_id]
          community_enrolled_program_leave_enrolled_programs_path(@entity, @enrollment)
        else
          client_client_enrolled_program_leave_enrolled_programs_path(@entity, @enrollment)
        end
      else
        if params[:family_id]
          family_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program)
        elsif params[:community_id]
          community_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program)
        else
          client_client_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program)
        end
      end
    end

    def leave_program_edit_link
      if params[:family_id]
        path = edit_family_enrollment_leave_program_path(@entity, @enrollment, @leave_program, program_stream_id: @program_stream)
      elsif params[:community_id]
        path = edit_community_enrollment_leave_program_path(@entity, @enrollment, @leave_program, program_stream_id: @program_stream)
      else
        path = edit_client_client_enrollment_leave_program_path(@entity, @enrollment, @leave_program, program_stream_id: @program_stream)
      end

      if program_permission_editable?(@program_stream)
        link_to path do
          content_tag :div, class: 'btn btn-success btn-outline' do
            fa_icon('pencil')
          end
        end
      else
        link_to_if false, path do
          content_tag :div, class: 'btn btn-success btn-outline disabled' do
            fa_icon('pencil')
          end
        end
      end
    end
  end
