class ClientsController < AdminController
  include ClientGridOptions

  load_and_authorize_resource find_by: :slug, except: :quantitative_case

  before_action :find_client, only: [:show, :edit, :update, :destroy]
  before_action :set_association, except: [:index, :destroy]
  before_action :choose_grid, only: :index

  def index
    columns_visibility
    respond_to do |f|
      f.html do
        @csi_statistics   = CsiStatistic.new(@client_grid.assets).assessment_domain_score.to_json
        @cases_statistics = CaseStatistic.new(@client_grid.assets).statistic_data.to_json
        @results          = @client_grid.scope { |scope| scope.accessible_by(current_ability) }.assets.size
        @client_grid.scope { |scope| scope.accessible_by(current_ability).page(params[:page]).per(20) }
      end
      f.xls do
        @client_grid.scope { |scope| scope.accessible_by(current_ability) }
        domain_score_report
        send_data @client_grid.to_xls, filename: "client_report-#{Time.now}.xls"
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        @ordered_client_answers     = @client.answers.order(:created_at)
        custom_field_ids            = @client.custom_field_properties.pluck(:custom_field_id)
        @free_client_forms          = CustomField.client_forms.not_used_forms(custom_field_ids).order_by_form_title
        @group_client_custom_fields = @client.custom_field_properties.sort_by{ |c| c.custom_field.form_title }.group_by(&:custom_field_id)
        initial_visit_client
      end
      format.pdf do
        render  pdf:      'show',
                template: 'clients/show.pdf.haml',
                page_size: 'A4',
                layout:   'pdf_design.html.haml',
                show_as_html: params.key?('debug'),
                header: { html: { template: 'government_reports/pdf/header.pdf.haml' } },
                footer: { html: { template: 'government_reports/pdf/footer.pdf.haml' }, right: '[page] of [topage]' },
                margin: { left: 0, right: 0 }
      end
    end
  end

  def new
    @client = Client.new

    @client.populate_needs
    @client.populate_problems

    @ordered_stage                       = Stage.order('from_age, to_age')
    @able_screening_questions            = AbleScreeningQuestion.with_stage.group_by(&:question_group_id)
    @able_screening_questions_non_stage  = AbleScreeningQuestion.non_stage.order('created_at')
    @able_screening_questions_with_stage = AbleScreeningQuestion.with_stage
    @answers_with_stage = []
    @answers_non_stage = []
    @able_screening_questions_with_stage.each do |question|
      @answers_with_stage << @client.answers.build(able_screening_question: question)
    end

    @able_screening_questions_non_stage.each do |question|
      @answers_non_stage << @client.answers.build(able_screening_question: question)
    end
  end

  def edit
    @ordered_stage                       = Stage.order('from_age, to_age')
    @able_screening_questions            = AbleScreeningQuestion.with_stage.group_by(&:question_group_id)

    @client.populate_needs unless @client.needs.any?
    @client.populate_problems unless @client.problems.any?
  end

  def create
    @client = Client.new(client_params)
    # @client.user_id = current_user.id if current_user.case_worker? || current_user.any_manager?

    if @client.save
      AbleScreeningMailer.notify_able_manager(@client).deliver_now if @client.able?
      redirect_to @client, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def update
    if @client.update_attributes(client_params)
      if params[:client][:assessment_id]
        @assessment = Assessment.find(params[:client][:assessment_id])
        redirect_to client_assessment_path(@client, @assessment), notice: t('.assessment_successfully_created')
      else
        redirect_to @client, notice: t('.successfully_updated')
      end
    else
      render :edit
    end
  end

  def destroy
    @client.reload.destroy

    redirect_to clients_url, notice: t('.successfully_deleted')
  end

  def quantitative_case
    if params[:id].blank?
      render json: QuantitativeCase.all, root: :data
    else
      render json: QuantitativeCase.quantitative_cases_by_type(params[:id]), root: :data
    end
  end

  def version
    page = params[:per_page] || 20
    @client   = Client.accessible_by(current_ability).friendly.find(params[:client_id]).decorate
    @versions = @client.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:id]).decorate
  end

  def client_params
    params.require(:client)
          .permit(
            :exit_note, :exit_date, :status,
            :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
            :birth_province_id, :initial_referral_date, :referral_source_id,
            :referral_phone, :received_by_id, :followed_up_by_id,
            :follow_up_date, :grade, :school_name, :current_address,
            :house_number, :street_number, :village, :commune, :district,
            :has_been_in_orphanage, :has_been_in_government_care,
            :relevant_referral_information, :province_id, :donor_id,
            :state, :rejected_note, :able, :able_state, :live_with, :id_poor, :accepted_date,
            :gov_city, :gov_commune, :gov_district, :gov_date, :gov_village_code, :gov_client_code,
            :gov_interview_village, :gov_interview_commune, :gov_interview_district, :gov_interview_city,
            :gov_caseworker_name, :gov_caseworker_phone, :gov_carer_name, :gov_carer_relationship, :gov_carer_home,
            :gov_carer_street, :gov_carer_village, :gov_carer_commune, :gov_carer_district, :gov_carer_city, :gov_carer_phone,
            :gov_information_source, :gov_referral_reason, :gov_guardian_comment, :gov_caseworker_comment,
            interviewee_ids: [],
            client_type_ids: [],
            user_ids: [],
            agency_ids: [],
            quantitative_case_ids: [],
            custom_field_ids: [],
            tasks_attributes: [:name, :domain_id, :completion_date],
            answers_attributes: [:id, :description, :able_screening_question_id, :client_id, :question_type],
            client_needs_attributes: [:id, :rank, :need_id],
            client_problems_attributes: [:id, :rank, :problem_id]
          )
  end

  def set_association
    @agencies        = Agency.order(:name)
    @donors          = Donor.order(:name)
    @province        = Province.order(:name)
    @referral_source = ReferralSource.order(:name)
    @users           = User.non_strategic_overviewers.order(:first_name, :last_name)
    @interviewees    = Interviewee.order(:created_at)
    @client_types    = ClientType.order(:created_at)
    @needs           = Need.order(:created_at)
    @problems        = Problem.order(:created_at)
  end

  def initial_visit_client
    referrer = Rails.application.routes.recognize_path(request.referrer)
    return unless referrer.present?
    white_list_referrers = %w(clients client_advanced_searches)
    controller_name = referrer[:controller]

    VisitClient.initial_visit_client(current_user) if white_list_referrers.include?(controller_name)
  end
end
