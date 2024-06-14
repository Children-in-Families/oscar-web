class FamilyReferralsController < AdminController
  load_and_authorize_resource

  before_action :find_family
  before_action :find_family_referral, only: [:show, :edit, :update]

  def index
    if params[:referral_type].presence == 'referred_to' || params[:referral_type].nil?
      @family_referrals = @family.family_referrals.delivered.most_recents
    else
      @family_referrals = @family.family_referrals.received_and_saved.most_recents
    end
  end

  def new
    if params[:ngo].present?
      @family_referral = @family.family_referrals.new({ referred_to: params[:ngo] })
    else
      @family_referral = @family.family_referrals.new
    end
  end

  def create
    @family_referral = @family.family_referrals.new(family_referral_params)
    if @family_referral.save
      redirect_to family_family_referral_path(@family, @family_referral), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
    authorize @family_referral
  end

  def show
    respond_to do |format|
      format.html { }
      format.pdf do
        form_title = "Referral Family To #{@family_referral.referred_to_ngo}"
        family_name = @family_referral.family
        pdf_name = "#{family_name} - #{form_title}"
        render pdf: pdf_name,
               template: 'family_referrals/show.pdf.haml',
               page_size: 'A4',
               layout: 'pdf_design.html.haml',
               show_as_html: params.key?('debug'),
               header: { html: { template: 'family_referrals/pdf/header.pdf.haml' } },
               footer: { html: { template: 'family_referrals/pdf/footer.pdf.haml' }, right: '[page] of [topage]' },
               margin: { left: 0, right: 0, top: 10 },
               dpi: '72',
               disposition: 'attachment'
      end
    end
  end

  def update
    authorize @family_referral
    if @family_referral.update_attributes(family_referral_params)
      redirect_to family_family_referral_path(@family, @family_referral), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  private

  def find_family_referral
    @family_referral = @family.family_referrals.find(params[:id])
  end

  def find_family
    @family = Family.accessible_by(current_ability).find(params[:family_id])
  end

  def family_referral_params
    params.require(:family_referral).permit(:referred_to, :referred_from, :name_of_referee, :referee_id,
                                            :referral_phone, :date_of_referral, :ngo_name, :referral_reason, :name_of_family, :slug, consent_form: [])
  end

  def find_external_system(external_name)
    ExternalSystem.find_by(name: external_name)&.name || ''
  end
end
