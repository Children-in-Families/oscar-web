class ProgressNoteTypesController < AdminController
  load_and_authorize_resource

  before_action :find_progress_note_type, only: [:update, :destroy]

  def index
    @progress_note_types = ProgressNoteType.order(:note_type).page(params[:page]).per(20)
    @results             = ProgressNoteType.count
  end

  def create
    @progress_note_type = ProgressNoteType.new(progress_note_type_params)
    if @progress_note_type.save
      redirect_to progress_note_types_path, notice: t('.successfully_created')
    else
      redirect_to progress_note_types_path, alert: t('.failed_create')
    end
  end

  def update
    if @progress_note_type.update_attributes(progress_note_type_params)
      redirect_to progress_note_types_path, notice: t('.successfully_updated')
    else
      redirect_to progress_note_types_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @progress_note_type.destroy
      redirect_to progress_note_types_url, notice: t('.successfully_deleted')
    else
      redirect_to progress_note_types_path, alert: t('.failed_delete')
    end
  end

  def version
    page = params[:per_page] || 20
    @progress_note_type = ProgressNoteType.find(params[:progress_note_type_id])
    @versions           = @progress_note_type.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def progress_note_type_params
    params.require(:progress_note_type).permit(:note_type)
  end

  def find_progress_note_type
    @progress_note_type = ProgressNoteType.find(params[:id])
  end
end
