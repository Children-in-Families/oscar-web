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
          params[:case_note][:case_note_domain_groups_attributes].each do |d|
            add_more_attachments(d.second[:attachments], d.second[:id])
          end
          case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes])
          render json: case_note
        else
          render json: case_note.errors, status: :unprocessable_entity
        end
      end

      private

      def case_note_params
        # params.require(:case_note).permit(:meeting_date, :attendee, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])

        default_params = params.require(:case_note).permit(:meetineg_date, :attendee, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])
        default_params = params.require(:case_note).permit(:meeting_date, :attendee, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids, attachments: []]) if action_name == 'create'
        default_params
      end

      def add_more_attachments(new_file, case_note_domain_group_id)
        if new_file.present?
          case_note_domain_group = @case_note.case_note_domain_groups.find(case_note_domain_group_id)
          files = case_note_domain_group.attachments
          files += new_file
          case_note_domain_group.attachments = files
          case_note_domain_group.save
        end
      end
    end
  end
end
