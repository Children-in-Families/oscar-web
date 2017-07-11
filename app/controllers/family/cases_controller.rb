class Family::CasesController < AdminController
  load_and_authorize_resource

  before_action :find_associations, :find_family

  def new
    @case = @family.cases.new
  end

  def create
    @case = @family.cases.new(case_params)
    if @case.save
      redirect_to family_path(@family), notice: t('.successfully_created')
    else
      render :new
    end
  end

  private
  def case_params
    params.require(:case).permit(:start_date, :carer_names, :carer_address,
                                  :province_id, :carer_phone_number,
                                  :support_amount, :case_type, :support_note,
                                  :partner_id, :client_id, :family_preservation)
  end

  def find_associations
    @clients   = Client.accessible_by(current_ability).accepted.where(status: 'Referred').order(:given_name, :family_name)
    @partners  = Partner.order(:name)
    @provinces = Province.order(:name)
  end

  def find_family
    @family = Family.find(params[:family_id])
  end
end