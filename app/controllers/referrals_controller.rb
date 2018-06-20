class ReferralsController < AdminController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_referral, only: [:show, :edit, :update]

  def index
    if params[:referral_type].presence == 'referred_to'
      @referrals = @client.referrals.delivered.most_recents
    else
      @referrals = @client.referrals.received_and_saved.most_recents
    end
  end

  def new
    if params[:ngo].present?
      @referral = @client.referrals.new({referred_to: params[:ngo]})
    else
      @referral = @client.referrals.new
    end
  end

  def create
    @referral = @client.referrals.new(referral_params)
    if @referral.save
      redirect_to client_referral_path(@client, @referral), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
    authorize @referral
  end

  def show
    respond_to do |format|
      format.html {}
      format.pdf do
        form           = params[:form]
        form_title     = "Referral Client To #{@referral.referred_to_ngo}"
        client_name    = @referral.client_name
        pdf_name       = "#{client_name} - #{form_title}"
        render  pdf:      pdf_name,
                template: 'referrals/show.pdf.haml',
                page_size: 'A4',
                layout:   'pdf_design.html.haml',
                show_as_html: params.key?('debug'),
                header: { html: { template: 'referrals/pdf/header.pdf.haml' } },
                footer: { html: { template: 'referrals/pdf/footer.pdf.haml' }, right: '[page] of [topage]' },
                margin: { left: 0, right: 0, top: 10 },
                dpi: '72',
                disposition: 'attachment'
      end
    end

  end

  def update
    authorize @referral
    if @referral.update_attributes(referral_params)
      redirect_to client_referral_path(@client, @referral), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  private

  def find_referral
    @referral = @client.referrals.find(params[:id])
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def referral_params
    params.require(:referral).permit(:referred_to, :referred_from, :name_of_referee, :referee_id, :referral_phone, :date_of_referral, :referral_reason, :client_name, :slug, consent_form: [])
  end
end
