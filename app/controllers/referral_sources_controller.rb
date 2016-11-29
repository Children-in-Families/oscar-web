class ReferralSourcesController < AdminController
  load_and_authorize_resource

  before_action :find_referral_source, only: [:update, :destroy]

  def index
    @referral_sources = ReferralSource.order(:name).page(params[:page]).per(10)
  end

  def create
    @referral_source = ReferralSource.new(referral_source_params)
    if @referral_source.save
      redirect_to referral_sources_path, notice: t('.successfully_created')
    else
      redirect_to referral_sources_path, alert: t('.failed_create')
    end
  end

  def update
    if @referral_source.update_attributes(referral_source_params)
      redirect_to referral_sources_path, notice: t('.successfully_updated')
    else
      redirect_to referral_sources_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @referral_source.clients_count.zero?
      @referral_source.destroy
      redirect_to referral_sources_url, notice: t('.successfully_deleted')
    else
      redirect_to referral_sources_path, alert: t('.failed_delete')
    end
  end

  def version
    @referral_source = ReferralSource.find(params[:referral_source_id])
    @versions        = @referral_source.versions.reorder(created_at: :desc).decorate
  end

  private

  def referral_source_params
    params.require(:referral_source).permit(:name, :description)
  end

  def find_referral_source
    @referral_source = ReferralSource.find(params[:id])
  end
end
