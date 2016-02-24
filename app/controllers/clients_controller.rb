class ClientsController < ApplicationController
  load_and_authorize_resource

  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :set_association, except: [:index, :destroy]

  def index
    if current_user.admin?
      @client_grid = ClientGrid.new(params[:client_grid])
    elsif current_user.case_worker?
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user))
    end
    respond_to do |f|
      f.html do
        if current_user.admin?
          @client_grid.scope {|scope| scope.paginate(page: params[:page], per_page: 20)}
        elsif current_user.case_worker?
          @client_grid.scope {|scope| scope.where(user_id: current_user.id).paginate(page: params[:page], per_page: 20)}
        end
      end
      f.csv do
        if current_user.admin?
          send_data @client_grid.to_csv,
            type: 'text/csv',
            disposition: 'inline',
            filename: "client_report-#{Time.now.to_s}.csv"
        elsif current_user.case_worker?
          send_data @client_grid.scope{|scope| scope.where(user_id: current_user.id)}.to_csv,
            type: 'text/csv',
            disposition: 'inline',
            filename: "client_report-#{Time.now.to_s}.csv"
        end
      end
    end
  end

  def show
    @client = if current_user.admin?
      Client.find(params[:id])
    else
      current_user.clients.find(params[:id])
    end
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client = Client.new(client_params)
    if current_user.case_worker?
      @client.user_id = current_user.id
    end

    if @client.save
      redirect_to @client, notice: 'Client has been successfully created.'
    else
      render :new
    end
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: 'Client has been successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_url, notice: 'Client has been successfully deleted.'
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    if current_user.admin?
      params.require(:client).permit(:first_name, :last_name, :gender, :date_of_birth, :status, :birth_province_id, :initial_referral_date, :referral_source_id, :referral_phone, :received_by_id, :followed_up_by_id, :follow_up_date, :school_grade, :school_name, :current_address, :has_been_in_orphanage, :able, :has_been_in_government_care, :relevant_referral_information, :user_id, :province_id, :state, :rejected_note, :completed, :agency_ids => [], :quantitative_case_ids => [])
    elsif current_user.case_worker?
      params.require(:client).permit(:first_name, :last_name, :gender, :date_of_birth, :status, :birth_province_id, :initial_referral_date, :referral_source_id, :referral_phone, :received_by_id, :followed_up_by_id, :follow_up_date, :school_grade, :school_name, :current_address, :has_been_in_orphanage, :able, :has_been_in_government_care, :relevant_referral_information, :province_id, :state, :rejected_note, :completed, :agency_ids => [], :quantitative_case_ids => [])
    end
  end

  def set_association
    @agencies        = Agency.order(:name)
    @province        = Province.order(:name)
    @referral_source = ReferralSource.order(:name)
    @user            = User.case_workers.order(:first_name, :last_name)
  end
end
