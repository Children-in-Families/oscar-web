module Api
  module V1
    class CaseNotesController < Api::V1::BaseApiController
      include CaseNoteConcern
      include CreateBulkTask
      include GoogleCalendarServiceConcern

      before_action :find_client

      def create
        case_note = @client.case_notes.new(case_note_params)
        case_note.assessment = @client.assessments.custom_latest_record
        case_note.meeting_date = "#{case_note.meeting_date.strftime("%Y-%m-%d")}, #{Time.now.strftime("%H:%M:%S")}"
        if case_note.save
          add_more_attachments(params[:case_note][:attachments]) if params.dig(:case_note, :attachments)
          case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes], current_user.id) if params.dig(:case_note, :case_note_domain_groups_attributes)
          create_bulk_task(params[:task], case_note) if params.key?(:task)
          case_note.complete_screening_tasks(params) if params[:case_note].key?(:tasks_attributes)

          create_task_task_progress_notes
          render json: case_note
        else
          if case_note_params[:custom] == 'true'
            @custom_assessment_param = case_note_params[:custom]
            case_note.assessment = @client.assessments.custom_latest_record
          else
            case_note.assessment = @client.assessments.default_latest_record
          end

          render json: case_note.errors, status: :unprocessable_entity
        end
      end

      def update
        case_note = @client.case_notes.find(params[:id])

        if case_note.update_attributes(case_note_params)
          if params.dig(:case_note, :case_note_domain_groups_attributes)
            add_more_attachments(params[:case_note][:attachments]) if params.dig(:case_note, :attachments)
            case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes], current_user.id)
          end
          create_bulk_task(params[:task], case_note) if params.key?(:task)
          # case_note.complete_screening_tasks(params) if params[:case_note].key?(:tasks_attributes)
          # create_task_task_progress_notes
          delete_events if session[:authorization]

          render json: case_note
        else
          render json: case_note.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if params[:file_index].present?
          remove_attachment_at_index(params[:file_index].to_i)
          head 204
        end
      end

      private

      def case_note_params
        default_params = permit_case_note_params
        default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, :custom, :note, :custom_assessment_setting_id, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids, attachments: []]) if action_name == 'create'
        default_params = assign_params_to_case_note_domain_groups_params(default_params) if default_params.dig(:case_note, :domain_group_ids)
        default_params = default_params.merge(selected_domain_group_ids: params.dig(:case_note, :domain_group_ids).reject(&:blank?))
        meeting_date   = "#{default_params[:meeting_date]} #{Time.now.strftime("%T %z")}"
        default_params.merge(meeting_date: meeting_date)
      end

      def add_more_attachments(new_file, case_note_domain_group_id)
        if new_file.present?
          case_note_domain_group = CaseNoteDomainGroup.find(case_note_domain_group_id)
          files = case_note_domain_group.attachments
          files += new_file
          case_note_domain_group.attachments = files
          case_note_domain_group.save
        end
      end
    end
  end
end
