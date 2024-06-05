class InternalReferralsController < AdminController
  before_action :find_client
  before_action :set_internal_referral, only: [:show, :edit, :update, :destroy]

  def index
    @internal_referrals = @client.internal_referrals
  end

  def show
  end

  def new
    @internal_referral = @client.internal_referrals.new
  end

  def edit
    authorize @internal_referral, :edit?
  end

  def create
    @internal_referral = InternalReferral.new(internal_referral_params)
    respond_to do |format|
      if @internal_referral.save
        format.html { redirect_to [@client, @internal_referral], notice: t('.successfully_created') }
        format.json { render :show, status: :created, location: @internal_referral }
      else
        format.html { render :new }
        format.json { render json: @internal_referral.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @internal_referral.update(internal_referral_params)
        format.html { redirect_to [@client, @internal_referral], notice: t('.successfully_updated') }
        format.json { render :show, status: :ok, location: @internal_referral }
      else
        format.html { render :edit }
        format.json { render json: @internal_referral.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @internal_referral.destroy
    respond_to do |format|
      format.html { redirect_to @client, notice: t('.successfully_deleted') }
      format.json { head :no_content }
    end
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id]) if params[:client_id]
  end

  def set_internal_referral
    @internal_referral = @client.internal_referrals.find(params[:id])
  end

  def internal_referral_params
    params.require(:internal_referral).permit(:referral_date, :client_id, :user_id, :client_representing_problem, :emergency_note, :referral_reason, :crisis_management, :referral_decision, attachments: [], program_stream_ids: [])
  end
end
