class CaseNotesController < AdminController
  before_action :find_client

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

  private

  def case_note_params
    params.require(:case_note).permit(:meeting_date, :attendee, case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids])
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end
end
