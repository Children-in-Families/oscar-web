class CasesController < ApplicationController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_case, only: [:edit, :update]
  before_action :find_association, except: [:index]

  def index
    @type  = params[:case_type]
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
      redirect_to @client, notice: 'Case has been successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @case.update(case_params)
        format.html { redirect_to @client, notice: 'Case has been successfully updated.' }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit }
        format.json { render json: @case.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def find_client
    @client  = Client.find(params[:client_id])
  end

  def case_params
    params.require(:case).permit(:start_date, :carer_names, :carer_address, :province_id, :carer_phone_number, :support_amount, :case_type, :support_note, :partner_id, :family_id, :exit_date, :exit_note, :exited, :family_preservation)
  end

  def find_association
    @family   = Family.order(:name)
    @partner  = Partner.order(:name)
    @province = Province.order(:name)
  end

  def find_case
    @case    = @client.cases.find(params[:id])
  end
end
