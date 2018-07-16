class GovernmentFormsController < AdminController
  load_and_authorize_resource
  before_action :find_association
  before_action :find_government_form, only: [:edit, :update, :destroy]
  before_action :find_form_name

  def index
    @government_forms = @client.government_forms.filter({ name: @form_name})
  end

  def new
    @government_form = @client.government_forms.new(name: @form_name)
    @government_form.populate_needs
    @government_form.populate_problems
    @government_form.populate_children_plans
    @government_form.populate_family_plans
  end

  def create
    @government_form = @client.government_forms.new(government_form_params)
    if @government_form.save
      redirect_to client_government_forms_path(@client, form: params[:form_num]), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    respond_to do |format|
      format.pdf do
        render  pdf:      'show',
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
    redirect_to client_government_forms_path(@client), notice: t('.successfully_deleted')
  end

  private

  def find_association
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
    @interviewees = Interviewee.order(:created_at)
    @client_types = ClientType.order(:created_at)
    @users = @client.users.order(:first_name, :last_name)
    @provinces = Province.order(:name)
    @districts = District.order(:name)
    @needs = Need.order(:created_at)
    @problems = Problem.order(:created_at)
  end

  def find_government_form
    @government_form = @client.government_forms.find(params[:id])
  end

  def government_form_params
    params.require(:government_form).permit(
      :name, :date, :village_code, :client_code, :interview_village,
      :interview_commune, :interview_district_id, :interview_province_id,
      :case_worker_id, :case_worker_phone, :primary_carer_relationship,
      :primary_carer_house, :primary_carer_street, :primary_carer_village,
      :primary_carer_commune, :primary_carer_district_id, :primary_carer_province_id,
      :source_info, :summary_info_of_referral, :guardian_comment, :case_worker_comment,
      interviewee_ids: [], client_type_ids: [],
      government_form_needs_attributes: [:id, :rank, :need_id],
      government_form_problems_attributes: [:id, :rank, :problem_id],
      government_form_children_plans_attributes: [:id, :goal, :action, :who, :when, :children_plan_id],
      government_form_family_plans_attributes: [:id, :goal, :action, :result, :family_plan_id]
    )
  end

  def find_form_name
    @form_name = case params[:form]
            when 'one' then 'ទម្រង់ទី១: ព័ត៌មានបឋម'
            when 'two' then ''
            when 'three' then 'ទម្រង់ទី៣: ផែនការសេវាសំរាប់ករណី​ និង គ្រួសារ'
            when 'four' then ''
            when 'five' then ''
            when 'sixe' then ''
            else nil
            end
    @form_name
  end
end
