class CaseNotesController < AdminController
  load_and_authorize_resource only: :destroy

  include CreateBulkTask
  include CaseNoteConcern
  include GoogleCalendarServiceConcern

  before_action :set_client
  before_action :set_case_note, only: [:edit, :update, :upload_attachment]
  before_action :fetch_domain_group, only: [:update, :edit]
  before_action :authorize_client, only: [:new]
  before_action :authorize_case_note, only: [:edit, :update]
  before_action -> { case_notes_permission('readable') }, only: [:index]
  before_action -> { case_notes_permission('editable') }, except: [:index]

  def index
    unless current_user.admin? || current_user.strategic_overviewer?
      redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_readable
    end

    @case_notes = @client.case_notes.recent_meeting_dates.page(params[:page])
    @custom_assessment_settings = CustomAssessmentSetting.all.where(enable_custom_assessment: true)
  end

  def new
    routes_params = params.to_unsafe_h.slice('from', 'custom', 'custom_name')
    redirect_to(edit_client_case_note_path(@client, routes_params.merge(id: :draft)))
  end

  def show
    @case_note = CaseNote.unscoped { @client.case_notes.find(params[:id]) }
  end

  def edit
    authorize @case_note, :edit? if Organization.ratanak?

    unless current_user.admin? || current_user.strategic_overviewer?
      redirect_to root_path, alert: t('unauthorized.default') if !@case_note.draft? && !current_user.permission.case_notes_editable
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
      create_task_task_progress_notes
      delete_events if session[:authorization]

      respond_to do |format|
        format.html do
          if params[:from_controller] == 'dashboards'
            redirect_to root_path, notice: t('.successfully_created')
          else
            redirect_to(client_case_notes_path(@client), notice: t('.successfully_updated'))
          end
        end

        format.json { render json: { resource: @case_note, edit_url: edit_client_case_note_url(@client, @case_note) }, status: 200 }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @case_note.errors, status: 422 }
      end
    end
  end

  def upload_attachment
    files = @case_note.attachments
    files += params.dig(:case_note, :attachments)
    @case_note.attachments = files
    @case_note.save(validate: false)

    render json: { message: t('.successfully_uploaded') }, status: '200'
  end

  def destroy
    if params[:file_index].present?
      remove_attachment_at_index(@case_note, params[:file_index].to_i)
      message ||= t('.successfully_deleted')
      respond_to do |f|
        f.json { render json: { message: message }, status: '200' }
      end
    elsif @case_note.present?
      @case_note.case_note_domain_groups.delete_all
      @case_note.reload.destroy
      redirect_to client_case_notes_path(@case_note.client), notice: t('.successfully_deleted_case_note')
    end
  end

  private

  def add_more_attachments(new_files)
    if new_files.present?
      case_note_domain_group = @case_note.case_note_domain_groups.first
      files = case_note_domain_group.attachments
      files += new_files
      case_note_domain_group.attachments = files
      case_note_domain_group.save
    end
  end

  def set_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def set_case_note
    @case_note = CaseNote.unscoped do
      if params[:id] == 'draft'
        @client.find_or_create_draft_case_note(
          custom_assessment_setting_id: set_custom_assessment_setting&.id,
          custom: params[:custom]
        )
      else
        @client.case_notes.find(params[:id])
      end
    end
  end

  def set_custom_assessment_setting
    @custom_assessment_setting = CustomAssessmentSetting.find_by(custom_assessment_name: params[:custom_name])
  end

  def authorize_case_note
    authorize @case_note
  end

  def authorize_client
    return true if current_user.admin?

    authorize @client, :create?
  end

  def case_notes_permission(permission)
    return if current_user.admin? || current_user.strategic_overviewer?

    if permission == 'readable'
      redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_readable
    else
      redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_editable
    end
  end

  def permit_case_note_params
    # tasks_attributes: [
    #   :id, :name, :completion_date, :completed, :completed_by_id, :_destroy,
    #   task_progress_notes_attributes: [:id, :progress_note, :task_id, :_destroy]
    # ]
    params.require(:case_note).permit(
      :meeting_date, :attendee, :interaction_type, :custom, :note, :custom_assessment_setting_id,
      case_note_domain_groups_attributes: [
        :id, :note, :domain_group_id, :task_ids
      ]
    )
  end
end
