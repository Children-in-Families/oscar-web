class StagesController < AdminController
  before_action :set_stage, only: [:show, :edit, :update]
  def index
    @stages = Stage.all
  end

  def show
  end

  def new
    @stage = Stage.new
  end

  def create
    @stage = Stage.new(stage_params)
    if @stage.save
      redirect_to stages_path
    else
      redirect_to stages_path, alert: 'Failed to create a stage'
    end
  end

  def edit
  end

  def update
    if @stage.update_attributes(stage_params)
      redirect_to stages_path
    else
      redirect_to stages_path, alert: 'Failed to update a stage'
    end
  end

  private
    def stage_params
      params.require(:stage).permit(
          :from_age, :to_age, :non_stage,
          able_screening_questions_attributes: [:id, :question, :mode,
            :question_group_id, :alert_manager, :_destroy,
            attachments_attributes: [:id, :image]])
    end
  protected
    def set_stage
      @stage = Stage.find(params[:id])
    end
end
