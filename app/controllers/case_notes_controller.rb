class CaseNotesController < ApplicationController

  before_action :find_client

  def index
    @case_notes = @client.case_notes.most_recents.paginate(per_page: 1, page: params[:page])
  end

  def new
    @case_note = @client.case_notes.new
    @case_note.assessment = Assessment.latest_record
    @case_note.populate_notes
  end

  def create
    @case_note = @client.case_notes.new(case_note_params)
    if @case_note.save
      @case_note.complete_tasks(params[:case_note][:case_note_domain_groups_attributes])
      redirect_to client_case_notes_path(@client), notice: 'Case Note has successfully been created.'
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
    if current_user.admin?
      @client = Client.find(params[:client_id])
    elsif current_user.case_worker?
      @client = current_user.clients.find(params[:client_id])
    end
  end

end
