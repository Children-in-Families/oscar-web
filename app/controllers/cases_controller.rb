class CasesController < AdminController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_case, only: [:edit, :update]
  before_action :find_association, except: [:index]
  before_action :can_create_case?, only: [:new, :create]
  before_action :set_custom_field, only: [:new, :create, :edit, :update]

  def index
    @type = params[:case_type]
    if @type == 'EC'
      @cases = @client.cases.emergencies.inactive
    elsif @type == 'FC'
      @cases = @client.cases.fosters.inactive
    elsif @type == 'KC'
      @cases = @client.cases.kinships.inactive
    end
  end

  def show
  end

  def new
    @case = @client.cases.new(case_type: params[:case_type])
  end

  def create
    @case = @client.cases.new(case_params)
    @case.user_id = @client.user.id if @client.user
    if @case.save
      redirect_to @client, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @case.update(case_params)
      redirect_to @client, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  private

  def find_client
    @client = Client.friendly.find(params[:client_id])
  end

  def case_params
    params.require(:case).permit(:start_date, :carer_names, :carer_address,
                                  :province_id, :carer_phone_number,
                                  :support_amount, :case_type, :support_note,
                                  :partner_id, :family_id, :exit_date,
                                  :exit_note, :exited, :family_preservation,
                                  :exited_from_cif, :status).merge(properties: (params['case']['properties']).to_json)
  end

  def find_association
    @family   = Family.order(:name)
    @partner  = Partner.order(:name)
    @province = Province.order(:name)
  end

  def set_custom_field
    @custom_field = CustomField.find_by(entity_name: 'Case')
  end

  def find_case
    @case = @client.cases.find(params[:id])
  end

  def can_create_case?
    return if @client.cases.active.size.zero?
    return if @client.cases.active.any? && @client.cases.current.exited
    return if @client.cases.current.case_type == 'EC'
    redirect_to @client, notice: t('.already_have_a_case')
  end
end
