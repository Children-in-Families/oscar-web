class ScreeningAssessmentsController <  AdminController
  load_and_authorize_resource params: :screening_assessment_params
  before_action :find_screening_assessment, except: [:index, :new, :create]
  before_action :authorize_screening_assessment, only: [:new, :create]
  before_action :find_client
  before_action :find_previous_screening_assessment, only: [:new, :create, :edit, :update]

  def index
    @screening_assessments = @client.screening_assessments.accessible_by(current_ability)
  end

  def new
    @screening_assessment = @client.screening_assessments.new
    @screening_assessment.populate_developmental_markers
    @screening_assessment.tasks.build(name: 'Refer to specialist')
  end

  def create
    @screning_assessment = @client.screening_assessments.new(screening_assessment_params)
    if @screning_assessment.screening_type == 'one_off'
      raise Pundit::NotAuthorizedError unless current_setting.cbdmat_one_off
    elsif @screning_assessment.screening_type == 'multiple'
      raise Pundit::NotAuthorizedError unless current_setting.cbdmat_ongoing
    end

    if @screening_assessment.save
      redirect_to [@client, @screening_assessment], noted: t('successfully_created', klass: 'Screening Assessment')
    else
      @screening_assessment.populate_developmental_markers
      flash[:alert] = @screening_assessment.errors.full_messages.join(', ')
      render :new, screening_type: @screning_assessment.screening_type
    end
  end

  def show
    @developmental_marker_screening_assessments = @screening_assessment.developmental_marker_screening_assessments.includes(:developmental_marker)
    @tasks = @screening_assessment.tasks
  end

  def edit
    @developmental_marker_screening_assessments = @screening_assessment.developmental_marker_screening_assessments
    maker_name = @screening_assessment.client_milestone_age
    @screening_assessment.populate_developmental_markers(maker_name)
    @screening_assessment.tasks.build(name: 'Refer to specialist') if @screening_assessment.tasks.blank?
  end

  def update
    if @screening_assessment.update_attributes(screening_assessment_params)
      redirect_to [@client, @screening_assessment], noted: t('successfully_updated', klass: 'Screening Assessment')
    else
      @screening_assessment.populate_developmental_markers
      flash[:alert] = @screening_assessment.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    if @screening_assessment.destroy
      redirect_to client_path(@client), notice: t('successfully_deleted', klass: 'Screening Assessment')
    else
      messages = @screening_assessment.errors.full_messages.uniq.join('\n')
      redirect_to [@client, @screening_assessment], alert: messages
    end
  end

  private

  def authorize_screening_assessment
    if @screning_assessment.screening_type == 'one_off'
      raise Pundit::NotAuthorizedError unless current_setting.cbdmat_one_off
    elsif @screning_assessment.screening_type == 'multiple'
      raise Pundit::NotAuthorizedError unless current_setting.cbdmat_ongoing
    end
  end

  def screening_assessment_params
    params.require(:screening_assessment).permit(
      :screening_assessment_date, :client_age, :visitor, :client_milestone_age, :note,
      :smile_back_during_interaction, :follow_object_passed_midline, :turn_head_to_sound,
      :head_up_45_degree, :screening_type, :client_id, attachments: [],
      developmental_marker_screening_assessments_attributes: [
        :id, :developmental_marker_id, :question_1, :question_2, :question_3, :question_4, :_destroy
      ],
      tasks_attributes: [:id, :client_id, :name, :expected_date, :completion_date, :taskable_id, :taskable_type, :relation, :_destroy]
    )
  end

  def find_screening_assessment
    @screening_assessment = ScreeningAssessment.find(params[:id])
  end

  def find_client
    @client = Client.friendly.find(params[:client_id])
  end

  def find_previous_screening_assessment
    @previous_screening_assessment = ScreeningAssessment.where(client_id: @client.id).last
  end
end
