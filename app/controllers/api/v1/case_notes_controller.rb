module Api
  module V1
    class CaseNotesController < Api::V1::BaseApiController
      before_action :find_client

      def create
        case_note = @client.case_notes.new(case_note_params)

        if case_note.save
          case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes])
          render json: case_note
        else
          render json: case_note.errors, status: :unprocessable_entity
        end
      end

      def update
        case_note = @client.case_notes.find(params[:id])

        if case_note.update_attributes(case_note_params)
          case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes])
          render json: case_note
        else
          render json: case_note.errors, status: :unprocessable_entity
        end
      end

      private

      def case_note_params
        params.require(:case_note).permit(:meeting_date, :attendee, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])
      end
    end
  end
end
