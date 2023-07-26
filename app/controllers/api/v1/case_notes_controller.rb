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
        end

        head 204 if CaseNote.find(params[:id]).destroy
      end
    end
  end
end
