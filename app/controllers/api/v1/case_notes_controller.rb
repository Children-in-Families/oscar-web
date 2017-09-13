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

      def destroy
        if params[:file_index].present?
          remove_attachment_at_index(params[:file_index].to_i)
          head 204
        end
      end

      private

      def case_note_params
        # params.require(:case_note).permit(:meeting_date, :attendee, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])

        default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])
        default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids, attachments: []]) if action_name == 'create'
        default_params
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

      def remove_attachment_at_index(index)
        case_note_domain_group = CaseNoteDomainGroup.find(params[:case_note_domain_group_id])
        remain_attachment = case_note_domain_group.attachments
        deleted_attachment = remain_attachment.delete_at(index)
        deleted_attachment.try(:remove!)
        remain_attachment.empty? ? case_note_domain_group.remove_attachments! : (case_note_domain_group.attachments = remain_attachment )
        message = t('.fail_delete_attachment') unless case_note_domain_group.save
      end
    end
  end
end
