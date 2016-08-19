class SurveysController < AdminController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_survey, only: [:edit, :update, :destroy]

  def index
    @surveys = @client.surveys
  end

  def new
    @survey = @client.surveys.new
  end

  def create
    @survey = @client.surveys.new(survey_params)
    if @survey.save
      redirect_to client_survey_path(@client, @survey), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    @survey = @client.surveys.find(params[:id]).decorate
  end

  def edit
  end

  def update
    if @survey.update_attributes(survey_params)
      redirect_to client_survey_path(@client, @survey), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_survey
    @survey = @client.surveys.find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(:listening_score, :problem_solving_score, :getting_in_touch_score, :trust_score, :difficulty_help_score, :support_score, :family_need_score, :care_score)
  end
end
