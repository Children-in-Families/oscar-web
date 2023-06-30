class CaseNotesController < AdminController
  load_and_authorize_resource only: :destroy

  include CreateBulkTask
  include CaseNoteConcern
  include GoogleCalendarServiceConcern

  before_action :set_client
  before_action :set_custom_assessment_setting, only: [:new, :create, :edit, :update]
  before_action :set_case_note, only: [:edit, :update, :upload_attachment]
  before_action :fetch_domain_group, only: [:new, :create, :update, :edit]
  before_action :authorize_client, only: [:new, :create]
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
    @from_controller = params[:from]
    if params[:custom] == 'true'
      @case_note = @client.case_notes.new(custom: true, custom_assessment_setting_id: @custom_assessment_setting&.id)
      @case_note.assessment = @client.assessments.custom_latest_record if @current_setting.enable_default_assessment
      @case_note.populate_notes(@case_note.custom_assessment_setting_id, params[:custom])
    else
      @case_note = @client.case_notes.new()
      @case_note.assessment = @client.assessments.default_latest_record
      @case_note.populate_notes(nil, 'false')
    end
  end

  def show
    @case_note = @client.case_notes.find(params[:id])
  end

  def edit
    if params[:id] == "draft"
      PaperTrail.without_tracking do
        if params[:custom] == 'true'
          @case_note.custom = true
          @case_note.custom_assessment = @custom_assessment_setting

          @case_note.assessment = @client.assessments.custom_latest_record if @current_setting.enable_default_assessment
          @case_note.populate_notes(@case_note.custom_assessment_setting_id, params[:custom])
        else
          @case_note.assessment = @client.assessments.default_latest_record
          @case_note.populate_notes(nil, 'false')
        end
      end
    else
      authorize @case_note, :edit? if Organization.ratanak?

      if @case_note.draft?
        if @case_note.custom?
          @case_note.populate_notes(@case_note.custom_assessment_setting_id, params[:custom])
        else
          @case_note.populate_notes(nil, 'false')
        end
      end

      unless current_user.admin? || current_user.strategic_overviewer?
        redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_editable
      end
    end
  end

  def update
    clean_case_note_domain_groups_attributes

    saved = if save_draft?
      PaperTrail.without_tracking do
        @case_note.assign_attributes(case_note_params.merge(last_auto_save_at: Time.current))
        @case_note.save(validate: false)
        clean_duplicate_case_note_domain_groups
      end
    else
      @case_note.draft = false
      @case_note.update_attributes(case_note_params)
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
        format.html { redirect_to(client_case_notes_path(@client), notice: t('.successfully_updated')) }
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
      remove_attachment_at_index(params[:file_index].to_i)
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

  def remove_attachment_at_index(index, case_note_domain_group_id = '')
    case_note_domain_group_id = params[:case_note_domain_group_id] || case_note_domain_group_id
    case_note_domain_group = CaseNoteDomainGroup.find(case_note_domain_group_id)
    remain_attachment = case_note_domain_group.attachments
    deleted_attachment = remain_attachment.delete_at(index)
    deleted_attachment.try(:remove_images!)
    remain_attachment.empty? ? case_note_domain_group.remove_attachments! : (case_note_domain_group.attachments = remain_attachment )
    t('.fail_delete_attachment') unless case_note_domain_group.save
  end

  def set_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def set_case_note
    if params[:id] == "draft"
      @case_note = @client.find_or_create_draft_case_note
    else
      @case_note = @client.case_notes.find(params[:id])
    end
  end

  def set_custom_assessment_setting
    @custom_assessment_setting = CustomAssessmentSetting.find_by(custom_assessment_name: params[:custom_name])
  end

  def authorize_case_note
    if params[:id] == "draft"
      return true if current_user.admin?
      authorize @client, :create?
    else
      authorize @case_note
    end
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
