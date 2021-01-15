class Family::ExitNgosController < AdminController

  before_action :find_family

  def create
    @exit_ngo = @family.exit_ngos.new(exit_ngo_params)
    if @exit_ngo.save
      send_reject_referral_family_email
      redirect_to @family, notice: t('.successfully_created')
    else
      redirect_to @family, alert: t('.failed_create')
    end
  end

  def update
    @exit_ngo = @family.exit_ngos.find(params[:id])
    authorize @exit_ngo
    if @exit_ngo.update_attributes(exit_ngo_params)
      redirect_to @family, notice: t('.successfully_updated')
    else
      redirect_to @family, alert: t('.failed_update')
    end
  end

  private

  def find_family
    @family = Family.find(params[:family_id])
  end

  def exit_ngo_params
    remove_blank_exit_reasons
    params.require(:exit_ngo).permit(:exit_note, :exit_circumstance, :other_info_of_exit, :exit_date, exit_reasons: [])
  end

  def remove_blank_exit_reasons
    return if params[:exit_ngo][:exit_reasons].blank?
    params[:exit_ngo][:exit_reasons].reject!(&:blank?)
  end

  def send_reject_referral_family_email
    return unless @family.family_referrals.received.present? && @exit_ngo.exit_circumstance == 'Rejected Referral'
    referral = @family.family_referrals.received.last
    current_org = current_organization.full_name
    RejectReferralFamilyWorker.perform_async(current_user.name, current_org, referral.id)
  end
end
