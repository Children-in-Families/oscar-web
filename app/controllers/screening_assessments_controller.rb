class ScreeningAssessmentsController <  AdminController
  load_and_authorize_resource params: :screening_assessment_params
  before_action :find_screening_assessment, except: [:index, :new, :create]
  before_action :find_client, only: [:new, :create, :show]

  def index
    @screening_assessments = ScreeningAssessment.includes(:client).accessible_by(current_ability)
  end

  def new
    @screening_assessment = @client.screening_assessments.new
  end

  def create
    @screning_assessment = @client.screening_assessments.new(screening_assessment_params)
    if @screening_assessment.save
      redirect_to [@client, @screening_assessment], noted: t('successfully_created', klass: 'Screening Assessment')
    else
      flash[:alert] = @screning_assessment.errors.full_messages
      render :new, screening_type: @screning_assessment.screening_type
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def screening_assessment_params
    params.require(:screening_assessment).permit(
      :screening_assessment_date, :client_age, :visitor, :client_milestone_age, :note,
      :smile_back_during_interaction, :follow_object_passed_midline, :turn_head_to_sound,
      :head_up_45_degree, :screening_type, :client_id, attachments: []
    )
  end

  def find_screening_assessment
    @screening_assessment = ScreeningAssessment.find(params[:id])
  end

  def find_client
    @client = Client.friendly.find(params[:client_id])
  end
end
