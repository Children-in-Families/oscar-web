class GovernmentFormsController < AdminController
  load_and_authorize_resource
  before_action :find_association
  before_action :find_government_form, only: [:edit, :update, :destroy]
  before_action :find_form_name, only: :index

  def index
    @government_forms = @client.government_forms.filter({ name: @form_name})
  end

  def new
    @government_form = @client.government_forms.new(name: params[:name])
  end

  def create
    @government_form = @client.create_government_form(government_form_params)
    if @government_form.save
      redirect_to client_government_forms_path, notice: t('.successfully_created')
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
  end

  def update
    if @government_form.update_attributes(government_form_params)
      redirect_to client_government_forms_path(@client), notice: t('.successfully_updated')
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
    @interviewees = Interviewee.order(:name)
  end

  def find_government_form
    @government_form = @client.government_form.decorate
  end

  def government_form_params
    params.require(:government_form).permit(:code, :initial_capital, :initial_city, :initial_commune, :initial_date, :commune, :city, :capital, :organisation_name, :organisation_phone_number, :found_client_at, :found_client_village, :education, :client_contact, :carer_house_number, :carer_street_number, :carer_village, :carer_commune, :carer_city, :referral_position, :anonymous, :anonymous_description, :client_living_with_guardian, :present_physical_health, :physical_health_need, :physical_health_plan, :present_supplies, :supplies_need, :supplies_plan, :present_education, :education_need, :education_plan, :present_family_communication, :family_communication_need, :family_communication_plan, :present_society_communication, :society_communication_need, :society_communication_plan, :present_emotional_health, :emotional_health_need, :emotional_health_plan, :mission_obtainable, :first_mission, :second_mission, :third_mission, :fourth_mission)
  end

  def find_form_name
    @form_name = case params[:form]
            when 'one' then 'ទម្រង់ទី១: ព័ត៌មានបឋម'
            when 'two' then ''
            when 'three' then ''
            when 'four' then ''
            when 'five' then ''
            when 'sixe' then ''
            else nil
            end
    @form_name
  end
end
