class CaseNotesController < AdminController
  load_and_authorize_resource
  before_action :set_client
  before_action :set_case_note, only: [:edit, :update]
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
    @case_note = @client.case_notes.new
    @case_note.assessment = @client.assessments.latest_record
    @case_note.populate_notes
  end

  def create
    @case_note = @client.case_notes.new(case_note_params)
    if @case_note.save
      @case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes])
      redirect_to client_case_notes_path(@client), notice: t('.successfully_created')
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

    default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])
    default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids, attachments: []]) if action_name == 'create'
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

  def remove_attachment_at_index(index)
    case_note_domain_group = CaseNoteDomainGroup.find(params[:case_note_domain_group_id])
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
end
