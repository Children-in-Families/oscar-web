class GovernmentFormsController < AdminController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_carer
  before_action :find_association, only: [:new, :create, :edit, :update]
  before_action :find_government_form, only: [:show, :edit, :update, :destroy]
  before_action :find_form_name
  before_action :find_static_association, only: :show

  def index
    @carer            = @client.carer
    @government_forms = @client.government_forms.filter({ name: @form_name})
  end

  def new
    if params[:copy] != "true"
      @government_form = @client.government_forms.new(name: @form_name)
      authorize @government_form
      @government_form.populate_needs
      @government_form.populate_problems
      if params[:form] == 'two' || params[:form] == 'six'
        @government_form.populate_children_status
        @government_form.populate_family_status(params[:form])
      elsif params[:form] == 'three'
        @government_form.populate_children_plans
        @government_form.populate_family_plans
      end
    else
      @government_form = @client.government_forms.find(params[:government_form_id]).decorate
      gov_attr = @government_form.merge_associations_params.except('id')
      @government_form =  @client.government_forms.new(gov_attr)
      authorize @government_form
    end
  end

  def create
    @government_form = @client.government_forms.new(government_form_params)
    authorize @government_form
    if @government_form.save
      redirect_to client_government_forms_path(@client, form: params[:form_num]), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    respond_to do |format|
      format.pdf do
        @client_tasks  = @client.tasks.incomplete.by_case_note.order(completion_date: :desc)
        @case_notes    = []

        @client.case_notes.order(meeting_date: :desc).each do |case_note|
          tasks = []
          case_note.case_note_domain_groups.each do |case_note_dg|
            case_note_dg.tasks.each do |task|
              tasks << task.name
            end
          end

          meeting_dates = case_note.meeting_date
          notes = case_note.note

          @case_notes << [meeting_dates, tasks, notes]
        end

        render  pdf:      @government_form.name,
                dpi:      '70',
                template: 'government_forms/show.pdf.haml',
                layout:   'pdf_design.html.haml',
                show_as_html: params.key?('debug'),
                header: { html: { template: 'government_forms/pdf/header.pdf.haml' } },
                footer: { html: { template: 'government_forms/pdf/footer.pdf.haml' }, right: '[page] of [topage]' },
                margin: { left: 0, right: 0 }
      end
    end
  end

  def edit
    @car
    @government_form.populate_needs unless @government_form.needs.any?
    @government_form.populate_problems unless @government_form.problems.any?
    @government_form.populate_children_plans unless @government_form.children_plans.any?
    @government_form.populate_family_plans unless @government_form.family_plans.any?
  end

  def update
    if @government_form.update_attributes(government_form_params)
      redirect_to client_government_forms_path(@client, form: params[:form_num]), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @government_form.destroy
    redirect_to client_government_forms_path(@client, form: params[:form]), notice: t('.successfully_deleted')
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
    current_org = Organization.current
    Organization.switch_to 'shared'
    client_record = SharedClient.find_by(slug: params[:client_id])
    if client_record.present?
      @client.given_name = client_record.given_name
      @client.family_name = client_record.family_name
      @client.local_given_name = client_record.local_given_name
      @client.local_family_name = client_record.local_family_name
      @client.gender = client_record.gender
      @client.date_of_birth = client_record.date_of_birth
      @client.telephone_number = client_record.telephone_number
      @client.live_with = client_record.live_with
      @client.birth_province_id = client_record.birth_province_id
    end
    Organization.switch_to current_org.short_name
  end

  def find_carer
    @carer = @client.carer
  end

  def find_association
    if params[:copy] == 'true'
      @government_form = GovernmentForm.find(params[:government_form_id])
    end
    @interviewees   = Interviewee.order(:created_at)
    @client_types   = ClientType.order(:created_at)
    @users          = @client.users.order(:first_name, :last_name)
    @provinces      = Province.official.order(:name)
    @districts      = @government_form.province.present? ? @government_form.province.districts.order(:code) : []
    @interviewee_districts   = @government_form.interview_province.present? ? @government_form.interview_province.districts.order(:code) : []
    @interview_communes      = @government_form.interview_district.present? ? @government_form.interview_district.communes.order(:code) : []
    @interview_villages      = @government_form.interview_commune.present? ? @government_form.interview_commune.villages.order(:code) : []
    @assessment_districts    = @government_form.assessment_province.present? ? @government_form.assessment_province.districts.order(:code) : []
    @assessment_communes     = @government_form.assessment_district.present? ? @government_form.assessment_district.communes.order(:code) : []
    @primary_carer_districts = @government_form.primary_carer_province.present? ? @government_form.primary_carer_province.districts.order(:code) : []
    @primary_carer_communes  = @government_form.primary_carer_district.present? ? @government_form.primary_carer_district.communes.order(:code) : []
    @primary_carer_villages  = @government_form.primary_carer_commune.present? ? @government_form.primary_carer_commune.villages.order(:code) : []
    @communes       = @government_form.district.present? ? @government_form.district.communes.order(:code) : []
    @villages       = @government_form.commune.present? ? @government_form.commune.villages.order(:code) : []
    @needs          = Need.order(:created_at)
    @problems       = Problem.order(:created_at)
    @service_types  = ServiceType.order(:created_at)
    @client_rights  = ClientRight.order(:created_at)
    @case_closures  = CaseClosure.order(:created_at)
  end

  def find_government_form
    @government_form = @client.government_forms.find(params[:id]).decorate
    authorize @government_form
  end

  def government_form_params
    params.require(:government_form).permit(
      :name, :date, :province_id, :district_id, :commune_id, :village_id, :client_code, :interview_village_id,
      :interview_commune_id, :interview_district_id, :interview_province_id,
      :assessment_commune_id, :assessment_district_id, :assessment_province_id,
      :case_worker_id, :case_worker_phone, :primary_carer_relationship,
      :primary_carer_house, :primary_carer_street, :primary_carer_village_id,
      :primary_carer_commune_id, :primary_carer_district_id, :primary_carer_province_id,
      :source_info, :summary_info_of_referral, :guardian_comment, :case_worker_comment,
      :other_interviewee, :other_need, :other_problem, :other_client_type, :gov_placement_date,
      :caseworker_assumption, :assumption_description, :assumption_date, :contact_type,
      :client_decision, :other_service_type, :recent_issues_and_progress, :other_case_closure, :case_closure_id, :brief_case_history,
      :care_type, :primary_carer, :secondary_carer, :carer_contact_info, :new_carer, :new_carer_gender, :new_carer_date_of_birth, :new_carer_relationship,
      interviewee_ids: [], client_type_ids: [], service_type_ids: [], client_right_ids: [],
      government_form_needs_attributes: [:id, :rank, :need_id],
      government_form_problems_attributes: [:id, :rank, :problem_id],
      government_form_children_plans_attributes: [:id, :goal, :action, :who, :completion_date, :score, :comment, :children_plan_id],
      government_form_family_plans_attributes: [:id, :goal, :action, :result, :score, :comment, :family_plan_id],
      action_results_attributes: [:id, :action, :result, :_destroy]
    )
  end

  def find_form_name
    @form_name = case params[:form]
            when 'one' then 'ទម្រង់ទី១: ព័ត៌មានបឋម'
            when 'two' then 'ទម្រង់ទី២: ការប៉ាន់ប្រមាណករណី និងគ្រួសារ'
            when 'three' then 'ទម្រង់ទី៣: ផែនការសេវាសំរាប់ករណី​ និង គ្រួសារ'
            when 'four' then 'ទម្រង់ទី៤: ការទុកដាក់កុមារ'
            when 'five'   then 'ទម្រង់ទី៥: តាមដាន និងត្រួតពិនិត្យ'
            when 'six' then 'ទម្រង់ទី៦: ប៉ាន់ប្រមាណចុងក្រោយ'
            else nil
            end
    @form_name
  end

  def find_static_association
    @user     = @government_form.case_worker_info
    @setting  = current_setting
    @guardian = @client.family.family_members.find_by(guardian: true) if @client.family.present?
    @father = @client.family.family_members.find_by(guardian: true, relation: 'Father') if @client.family.present?
    @mother = @client.family.family_members.find_by(guardian: true, relation: 'Mother') if @client.family.present?
  end
end
