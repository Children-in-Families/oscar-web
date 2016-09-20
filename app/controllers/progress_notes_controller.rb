class ProgressNotesController < AdminController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_progress_note, only: [:show, :edit, :update, :destroy]
  before_action :find_association, only: [:new, :create, :edit, :update]

  def index
    @progress_notes = @client.progress_notes.all.paginate(page: params[:page], per_page: 20)
  end

  def new
    @progress_note = @client.progress_notes.new
  end

  def create
    @progress_note = @client.progress_notes.new(progress_note_params)
    if @progress_note.save
      redirect_to client_progress_note_path(@client, @progress_note), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    @progress_note = @client.progress_notes.find(params[:id])
  end

  def edit
  end

  def update
    if @progress_note.update_attributes(progress_note_params)
      redirect_to client_progress_note_path(@client, @progress_note), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @progress_note.destroy
    redirect_to client_progress_notes_url, notice: t('.successfully_deleted')
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_progress_note
    @progress_note = @client.progress_notes.find(params[:id])
  end

  def find_association
    @progress_note_types = ProgressNoteType.order(:note_type)
    @locations           = Location.order(:name)
    @interventions       = Intervention.order(:action)
    @materials           = Material.order(:status)
  end

  def progress_note_params
    params.require(:progress_note).permit(:date, :progress_note_type_id, :location_id, :other_location, :material_id, :response, :additional_note, intervention_ids: [])
  end
end
