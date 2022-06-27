 class CaseNotesController < AdminController
  load_and_authorize_resource
  include CreateBulkTask
  include CaseNoteConcern
  include GoogleCalendarServiceConcern

  before_action :set_client
  before_action :set_custom_assessment_setting, only: [:new, :create, :edit, :update]
  before_action :set_case_note, only: [:edit, :update]
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

  def create
    @case_note = @client.case_notes.new(case_note_params)
    @case_note.meeting_date = "#{@case_note.meeting_date.strftime("%Y-%m-%d")}, #{Time.now.strftime("%H:%M:%S")}"
    if @case_note.save
      add_more_attachments(params[:case_note][:attachments]) if params.dig(:case_note, :attachments)
      @case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes], current_user.id) if params.dig(:case_note, :case_note_domain_groups_attributes)
      create_bulk_task(params[:task], @case_note) if params.has_key?(:task)
      if params[:from_controller] == "dashboards"
        redirect_to root_path, notice: t('.successfully_created')
      else
        redirect_to client_case_notes_path(@client), notice: t('.successfully_created')
      end
    else
      if case_note_params[:custom] == 'true'
        @custom_assessment_param = case_note_params[:custom]
        @case_note.assessment = @client.assessments.custom_latest_record
      else
        @case_note.assessment = @client.assessments.default_latest_record
      end
      @case_note_domain_group_note = params.dig(:additional_fields, :note)
      render :new
    end
  end

  def show
    @case_note = @client.case_notes.find(params[:id])
  end

  def edit
    authorize @case_note, :edit? if Organization.ratanak?
    unless current_user.admin? || current_user.strategic_overviewer?
      redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_editable
    end
  end

  def update
    if @case_note.update_attributes(case_note_params)
      # if params.dig(:case_note, :case_note_domain_groups_attributes)
      #   add_more_attachments(params[:case_note][:attachments]) if params.dig(:case_note, :attachments)
      #   @case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes], current_user.id)
      # end
      # create_bulk_task(params[:task], @case_note) if params.has_key?(:task)
      delete_events if session[:authorization]
      redirect_to client_case_notes_path(@client), notice: t('.successfully_updated')
    else
      render :edit
    end
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

  def case_note_params
    default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, :custom, :note, :custom_assessment_setting_id,
      case_note_domain_groups_attributes: [
        :id, :note, :domain_group_id, :task_ids,
        tasks_attributes: [
          :id, :name, :completion_date, :completed, :completed_by_id, :case_note_domain_group_id, :_destroy,
          task_progress_notes_attributes: [:id, :progress_note, :task_id, :_destroy]
        ]
      ]
    )
    # default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, :custom, :note, :custom_assessment_setting_id, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids, attachments: []]) if action_name == 'create'
    default_params = assign_params_to_case_note_domain_groups_params(default_params) if default_params.dig(:case_note, :domain_group_ids)
    default_params = default_params.merge(selected_domain_group_ids: params.dig(:case_note, :domain_group_ids).reject(&:blank?))
    meeting_date   = "#{default_params[:meeting_date]} #{Time.now.strftime("%T %z")}"
    default_params = default_params.merge(meeting_date: meeting_date)
  end

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
    message = t('.fail_delete_attachment') unless case_note_domain_group.save
  end

  def set_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def set_case_note
    @case_note = @client.case_notes.find(params[:id])
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
    unless current_user.admin? || current_user.strategic_overviewer?
      if permission == 'readable'
        redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_readable
      else
        redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_editable
      end
    end
  end
end
