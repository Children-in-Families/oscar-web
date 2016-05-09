class GovernmentReportsController < AdminController

  before_action :find_client
  before_action :find_government_report, only: [:show, :edit, :update, :destroy]
  
  def index
    @government_reports = @client.government_reports.all
  end
  
  def new
    @government_report = @client.government_reports.new
  end

  def create
    @government_report = @client.government_reports.new(government_report_params)
    if @government_report.save
      redirect_to client_government_reports_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    respond_to do |format|
      format.pdf do
        render  pdf:      'show',
                template: 'government_reports/show.pdf.haml',
                layout:   'pdf_design.html.haml',
                header: { html: { template: 'government_reports/pdf/header.pdf.haml' } },
                footer: { html: { template: 'government_reports/pdf/footer.pdf.haml' },
                right: '[page] of [topage]'
              }
      end
    end
  end

  def edit
  end

  def update
    if @government_report.update_attributes(government_report_params)
      redirect_to client_government_reports_path(@client), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @government_report.destroy
    redirect_to client_government_reports_path(@client), notice: t('.successfully_deleted')
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_government_report
    @government_report = @client.government_reports.find(params[:id])
  end

  def government_report_params
    params.require(:government_report).permit(:code, :initial_capital, :initial_city, :initial_commune, :initial_date, :commune, :city, :capital, :organisation_name, :organisation_phone_number, :found_client_at, :found_client_village, :education, :client_contact, :carer_house_number, :carer_street_number, :carer_village, :carer_commune, :carer_capital, :referral_name, :referral_position, :anonymous, :anonymous_description, :client_living_with_guardian, :present_physical_health, :physical_health_need, :physical_health_plan, :present_supplies, :supplies_need, :supplies_plan, :present_education, :education_need, :education_plan, :present_family_communication, :family_communication_need, :family_communication_plan, :present_society_communication, :society_communication_need, :society_communication_plan, :present_emotional_health, :emotional_health_need, :emotional_health_plan, :mission_obtainable, :first_mission, :second_mission, :third_mission, :fourth_mission, :done_date, :agreed_date, :quantitative_case_ids => [])
  end
  
end