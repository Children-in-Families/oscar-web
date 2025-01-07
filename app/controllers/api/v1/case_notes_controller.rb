module Api
  module V1
    class CaseNotesController < Api::V1::BaseApiController
      include CaseNoteConcern
      include CreateBulkTask
      include GoogleCalendarServiceConcern

      before_action :find_client, only: [:create, :update]
      before_action :set_case_note, only: [:show, :update, :upload_attachment, :destroy, :delete_attachment]
      before_action :authorize_case_note, only: [:edit, :update]
      before_action -> { case_notes_permission('readable') }, only: [:index]
      before_action -> { case_notes_permission('editable') }, except: [:index]

      def show
        render json: @case_note
      end

      def create
        case_note = if params[:id] == 'draft'
                      @client.find_or_create_draft_case_note(
                        **case_note_params,
                        custom_assessment_setting_id: set_custom_assessment_setting&.id,
                        custom: params[:custom]
                      )
                    else
                      @client.case_notes.new(case_note_params)
                    end
        case_note.assessment = @client.assessments.custom_latest_record
        case_note.meeting_date = "#{case_note.meeting_date.strftime('%Y-%m-%d')}, #{Time.now.strftime('%H:%M:%S')}"
        if (case_note.persisted? && case_note.save(validate: false)) || case_note.save
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
        attributes = case_note_params.merge(last_auto_save_at: Time.current)
        saved = if save_draft?
                  @case_note.assign_attributes(attributes)
                  PaperTrail.without_tracking { @case_note.save(validate: false) }

                  true
                else
                  @case_note.update_attributes(case_note_params.merge(draft: false))
                end

        if saved
          if params.dig(:case_note, :case_note_domain_groups_attributes)
            @case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes], current_user.id)
          end

          create_bulk_task(params[:task], @case_note) if params.key?(:task)
          @case_note.complete_screening_tasks(params) if params[:case_note].key?(:tasks_attributes)

          # As we don't allow edit progress note once saved,
          # do not save it if request sent by autosave
          create_task_task_progress_notes unless save_draft?
          delete_events if session[:authorization]

          render json: { resource: @case_note, edit_url: edit_client_case_note_url(@client, @case_note) }, status: 200
        else
          render json: @case_note.errors, status: 422
        end
      end

      def upload_attachment
        files = @case_note.attachments
        files += params.dig(:case_note, :attachments) || []
        @case_note.attachments = files
        @case_note.save(validate: false)

        render json: { message: t('.successfully_uploaded') }, status: '200'
      end

      def destroy
        if params[:file_index].present?
          remove_attachment_at_index(@case_note, params[:file_index].to_i)
        end

        head 204 if @case_note.destroy
      end

      def delete_attachment
        remove_attachment_at_index(@case_note, params[:file_index].to_i)
        if @case_note.save
          head 204
        else
          render json: @case_note.errors, status: :unprocessable_entity
        end
      end

      private

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

      def case_notes_permission(permission)
        return if current_user.admin? || current_user.strategic_overviewer?

        if permission == 'readable'
          render json: { message: t('unauthorized.default') }, status: :unprocessable_entity unless current_user.permission.case_notes_readable
        else
          render json: { message: t('unauthorized.default') }, status: :unprocessable_entity unless current_user.permission.case_notes_editable
        end
      end
    end
  end
end
