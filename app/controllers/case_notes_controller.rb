class CaseNotesController < AdminController
  load_and_authorize_resource
  before_action :set_client
  before_action :set_case_note, only: [:edit, :update]

  def index
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
  end

  def update
    authorize @case_note
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

    default_params = params.require(:case_note).permit(:meeting_date, :attendee, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])
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

  def remove_attachment_at_index(index)
    case_note_domain_group = CaseNoteDomainGroup.find(params[:case_note_domain_group])
    remain_attachment = case_note_domain_group.attachments
    deleted_attachment = remain_attachment.delete_at(index)
    deleted_attachment.try(:remove!)
    remain_attachment.empty? ? case_note_domain_group.remove_attachments! : (case_note_domain_group.attachments = remain_attachment )
    message = "Failed deleting attachment" unless case_note_domain_group.save
  end

  def set_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def set_case_note
    @case_note = @client.case_notes.find(params[:id])
  end
end
