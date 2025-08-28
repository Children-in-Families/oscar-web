module Api
  module V1
    class Families::CaseNotesController < Api::V1::BaseApiController
      include CaseNoteConcern
      include CreateBulkTask
      include GoogleCalendarServiceConcern

      before_action :set_family, except: :show

      def index
        case_notes = @family.case_notes
        render json: case_notes
      end

      def show
        case_note = CaseNote.find(params[:id])
        render json: case_note
      end

      def create
        case_note = @family.case_notes.new(case_note_params)
        case_note.assessment = @family.assessments.custom_latest_record if case_note_params[:custom] == 'true'
        case_note.meeting_date = "#{case_note.meeting_date.strftime('%Y-%m-%d')}, #{Time.now.strftime('%H:%M:%S')}"
        if case_note.save
          case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes], current_user.id) if params.dig(:case_note, :case_note_domain_groups_attributes)
          create_bulk_task(params[:task], case_note) if params.key?(:task)
          case_note.complete_screening_tasks(params) if params[:case_note].key?(:tasks_attributes)

          create_task_task_progress_notes
          render json: case_note
        else
          if case_note_params[:custom] == 'true'
            @custom_assessment_param = case_note_params[:custom]
            case_note.assessment = @family.assessments.custom_latest_record
          else
            case_note.assessment = @family.assessments.default_latest_record
          end

          render json: case_note.errors, status: :unprocessable_entity
        end
      end

      def update
        case_note = @family.case_notes.find(params[:id])

        if case_note.update_attributes(case_note_params)
          if params.dig(:case_note, :case_note_domain_groups_attributes)
            case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes], current_user.id)
          end
          create_bulk_task(params[:task], case_note) if params.key?(:task)
          case_note.complete_screening_tasks(params) if params[:case_note].key?(:tasks_attributes)
          # create_task_task_progress_notes
          delete_events if session[:authorization]

          render json: case_note
        else
          render json: case_note.errors, status: :unprocessable_entity
        end
      end

      def destroy
        case_note = CaseNote.find(params[:id])
        if params[:file_index].present?
          remove_attachment_at_index(case_note, params[:file_index].to_i)
        end

        head 204 if case_note.destroy
      end

      def delete_attachment
        case_note = CaseNote.find(params[:id])
        remove_attachment_at_index(case_note, params[:file_index].to_i)
        if case_note.save
          head 204
        else
          render json: case_note.errors, status: :unprocessable_entity
        end
      end

      private

      def set_family
        @family = Family.accessible_by(current_ability).find(params[:family_id])
      end

      def remove_attachment_at_index(case_note, index)
        remain_attachments = case_note.attachments
        if index.zero? && case_note.attachments.size == 1
          case_note.remove_attachments!
        else
          deleted_attachment = remain_attachments.delete_at(index)
          deleted_attachment.try(:remove!)
          case_note.attachments = remain_attachments
        end
      end
    end
  end
end
