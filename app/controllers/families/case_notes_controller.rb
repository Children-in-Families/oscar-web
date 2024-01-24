class Families::CaseNotesController < ::AdminController
  load_and_authorize_resource
  include CreateBulkTask
  include CaseNoteConcern

  before_action :set_family
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
    @case_notes = @family.case_notes.recent_meeting_dates.page(params[:page])
    @custom_assessment_settings = CustomAssessmentSetting.all.where(enable_custom_assessment: true)
  end

  def new
    @from_controller = params[:from]
    @case_note = @family.case_notes.new(custom: true)
    @case_note.assessment = @family.assessments.custom_latest_record
    @case_note.populate_notes(nil, 'false')
  end

  def create
    @case_note = @family.case_notes.new(case_note_params)
    @case_note.meeting_date = "#{@case_note.meeting_date.strftime('%Y-%m-%d')}, #{Time.now.strftime('%H:%M:%S')}"
    if @case_note.save
      add_more_attachments(params[:case_note][:attachments]) if params.dig(:case_note, :attachments)
      @case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes], current_user.id) if params.dig(:case_note, :case_note_domain_groups_attributes)
      create_bulk_task(params[:task], @case_note) if params.has_key?(:task)
      if params[:from_controller] == 'dashboards'
        redirect_to root_path, notice: t('case_notes.create.successfully_created')
      else
        redirect_to family_case_notes_path(@family), notice: t('case_notes.create.successfully_created')
      end
    else
      @custom_assessment_param = true
      @case_note.assessment = @family.assessments.default_latest_record

      @case_note_domain_group_note = params.dig(:additional_fields, :note)
      render :new
    end
  end

  def show
    @case_note = @family.case_notes.find(params[:id])
  end

  def edit
    @case_note.populate_notes(nil, 'false')
    unless current_user.admin? || current_user.strategic_overviewer?
      redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_editable
    end
  end

  def update
    if @case_note.update_attributes(case_note_params) && @case_note.save
      if params.dig(:case_note, :case_note_domain_groups_attributes)
        add_more_attachments(params[:case_note][:attachments]) if params.dig(:case_note, :attachments)
        @case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes], current_user.id)
      end
      create_bulk_task(params[:task], @case_note) if params.has_key?(:task)
      @case_note.tasks.update_all(completion_date: @case_note.meeting_date)
      redirect_to family_case_notes_path(@family), notice: t('case_notes.update.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if params[:file_index].present?
      remove_attachment_at_index(params[:file_index].to_i)
      message ||= t('case_notes.destroy.successfully_deleted')
      respond_to do |f|
        f.json { render json: { message: message }, status: '200' }
      end
    elsif @case_note.present?
      @case_note.case_note_domain_groups.delete_all
      @case_note.reload.destroy
      redirect_to family_case_notes_path(@case_note.parent), notice: t('case_notes.destroy.successfully_deleted_case_note')
    end
  end

  private

  def case_note_params
    default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, :custom, :note, :custom_assessment_setting_id, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])
    default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, :custom, :note, :custom_assessment_setting_id, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids, attachments: []]) if action_name == 'create'
    default_params = assign_params_to_case_note_domain_groups_params(default_params) if default_params.dig(:case_note, :domain_group_ids)
    default_params = default_params.merge(selected_domain_group_ids: params.dig(:case_note, :domain_group_ids).reject(&:blank?))
    meeting_date = "#{default_params[:meeting_date]} #{Time.now.strftime('%T %z')}"
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
    remain_attachment.empty? ? case_note_domain_group.remove_attachments! : (case_note_domain_group.attachments = remain_attachment)
    t('case_notes.destroy.fail_delete_attachment') unless case_note_domain_group.save
  end

  def set_family
    @family = Family.accessible_by(current_ability).find(params[:family_id])
  end

  def set_case_note
    @case_note = @family.case_notes.find(params[:id])
  end

  def set_custom_assessment_setting
    @custom_assessment_setting = CustomAssessmentSetting.find_by(custom_assessment_name: params[:custom_name])
  end

  def authorize_case_note
    authorize @case_note
  end

  def authorize_client
    authorize @family, :create?
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

  def fetch_domain_group
    @domain_groups = []
    if params[:action].in? ['edit', 'update']
      if @case_note.domain_groups.present?
        @domain_groups = @case_note.domain_groups.distinct_by_family_domains
      else
        @domain_groups = DomainGroup.joins(:domains).where(domains: { id: Domain.family_custom_csi_domains.ids }).where(id: @case_note.selected_domain_group_ids)
      end
    else
      domain_group_ids = Domain.family_custom_csi_domains.pluck(:domain_group_id).uniq
      @domain_groups = DomainGroup.where(id: domain_group_ids)
    end

    case_note_domain_groups = CaseNoteDomainGroup.where(case_note: @case_note, domain_group_id: @domain_groups.map(&:id))
    @case_note_domain_group_note = case_note_domain_groups.where.not(note: '').map do |cndg|
      group_name = cndg.domains(@case_note).map(&:identity).join(', ')
      "#{group_name}\n#{cndg.note}"
    end.join("\n\n").html_safe
  end
end
