class CaseNotesController < AdminController
  load_and_authorize_resource
  include CreateBulkTask

  before_action :set_client
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
    @case_notes = @client.case_notes.most_recents.page(params[:page]).per(1)
  end

  def new
    @from_controller = params[:from]
    if params[:custom] == 'true'
      @case_note = @client.case_notes.new(custom: true)
      @case_note.assessment = @client.assessments.custom_latest_record
      @case_note.populate_notes
    else
      @case_note = @client.case_notes.new
      @case_note.assessment = @client.assessments.default_latest_record
      @case_note.populate_notes
    end
  end

  def create
    @case_note = @client.case_notes.new(case_note_params)
    if @case_note.save
      @case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes])

      create_bulk_task(params[:task], @case_note.id) if params.has_key?(:task)
      if params[:from_controller] == "dashboards"
        redirect_to root_path, notice: t('.successfully_created')
      else
        redirect_to client_case_notes_path(@client), notice: t('.successfully_created')
      end
    else
      render :new
    end
  end

  def show
    @case_note = @client.case_notes.find(params[:id])
  end

  def edit
    unless current_user.admin? || current_user.strategic_overviewer?
      redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_editable
    end
  end

  def update
    if @case_note.update_attributes(case_note_params) && @case_note.save
      params[:case_note][:case_note_domain_groups_attributes].each do |d|
        add_more_attachments(d.second[:attachments], d.second[:id])
      end
      @case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes])
      create_bulk_task(params[:task], @case_note.id) if params.has_key?(:task)
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
    end
  end

  private

  def case_note_params
    # params.require(:case_note).permit(:meeting_date, :attendee, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])

    default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, :custom, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])
    default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, :custom, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids, attachments: []]) if action_name == 'create'
    default_params = assign_params_to_case_note_domain_groups_params(default_params)
    default_params
  end

  def assign_params_to_case_note_domain_groups_params(default_params)
    note = params.dig(:additional_fields, :note)
    attachments = params.dig(:case_note, :attachments)
    domain_group_ids = params.dig(:case_note, :domain_group_ids).reject(&:blank?)
    case_note_domain_groups = default_params[:case_note_domain_groups_attributes]

    selected_case_note_domain_groups = case_note_domain_groups.select{|key, value| domain_group_ids.include? value["domain_group_id"]}
    selected_case_note_domain_groups.values.each do |value|
      value['note'] = note
      value['attachments'] = attachments if params[:action] == 'create'
    end

    non_selected_case_note_domain_groups = case_note_domain_groups.select{|key, value| domain_group_ids.exclude? value["domain_group_id"]}
    non_selected_case_note_domain_groups.values.each do |value|
      value['note'] = ''
      next if params[:action] == 'create'
      cndg_id = value['id'].to_i
      cndg_attachments = CaseNoteDomainGroup.find(cndg_id).attachments
      cndg_attachments.each_with_index do |attachment, index|
        remove_attachment_at_index(index, cndg_id)
      end
    end
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

  def authorize_case_note
    authorize @case_note
  end

  def authorize_client
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

  def fetch_domain_group
    @domain_groups = []
    if params[:action].in? ['edit', 'update']
      @domain_groups = @case_note.domain_groups
    else
      domains = params[:custom] == 'true' ? 'custom_csi_domains' : 'csi_domains'
      domain_group_ids = Domain.send("#{domains}").pluck(:domain_group_id).uniq
      @domain_groups = DomainGroup.where(id: domain_group_ids)
    end

    case_note_domain_groups = CaseNoteDomainGroup.where(case_note: @case_note, domain_group: @domain_groups)
    @case_note_domain_group_note = case_note_domain_groups.where.not(note: '').try(:first).try(:note)
    @selected_domain_group_ids = case_note_domain_groups.where("attachments != '{}' OR note != ''").pluck(:domain_group_id)
  end
end
