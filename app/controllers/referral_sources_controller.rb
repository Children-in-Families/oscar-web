class ReferralSourcesController < AdminController
  load_and_authorize_resource

  before_action :find_referral_source, only: [:edit, :update, :destroy]

  def index
    @referral_sources = ReferralSource.all.paginate(page: params[:page], per_page: 20)
  end

  def new
    @referral_source = ReferralSource.new
  end

  def create
    @referral_source = ReferralSource.new(referral_source_params)
    if @referral_source.save
      redirect_to referral_sources_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @referral_source.update_attributes(referral_source_params)
      redirect_to referral_sources_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @referral_source.clients_count.zero?
      @referral_source.destroy
      redirect_to referral_sources_url, notice: t('.successfully_deleted')
    else
      redirect_to referral_sources_url, alert: t('.alert')
    end
  end

  private

  def referral_source_params
    params.require(:referral_source).permit(:name, :description)
  end

  def find_referral_source
    @referral_source = ReferralSource.find(params[:id])
  end
end
