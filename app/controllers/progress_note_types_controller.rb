class ProgressNoteTypesController < AdminController
  load_and_authorize_resource

  before_action :find_progress_note_type, only: [:edit, :update, :destroy]

  def index
    @progress_note_types = ProgressNoteType.order(:note_type).paginate(page: params[:page], per_page: 20)
  end

  def new
    @progress_note_type = ProgressNoteType.new
  end

  def create
    @progress_note_type = ProgressNoteType.new(progress_note_type_params)
    if @progress_note_type.save
      redirect_to progress_note_types_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @progress_note_type.update_attributes(progress_note_type_params)
      redirect_to progress_note_types_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @progress_note_type.destroy
      redirect_to progress_note_types_url, notice: t('.successfully_deleted')
    else
      redirect_to progress_note_types_url, notice: t('.unsuccessfully_deleted')
    end
  end

  private

  def progress_note_type_params
    params.require(:progress_note_type).permit(:note_type)
  end

  def find_progress_note_type
    @progress_note_type = ProgressNoteType.find(params[:id])
  end
end
