class OrganizationClientSerializer < ActiveModel::Serializer
  include ActionView::Helpers::AssetUrlHelper
  include OrganizationSerializerConcern

  attributes :slug, :global_id, :external_id, :external_id_display, :mosvy_number, :mosvy_number, :given_name, :family_name,
             :gender, :date_of_birth, :location_current_village_code, :address_current_village_code,
             :organization_id, :organization_name, :external_case_worker_name, :external_case_worker_id,
             :reason_for_referral, :status, :case_worker_name, :case_worker_mobile,
             :is_referred, :referral_consent_form, :organization_address_code, :level_of_risk, :services

  def given_name
    object.given_name.presence || object.local_given_name
  end

  def family_name
    object.family_name.presence || object.local_family_name
  end

  def organization_id
    Organization.current.id
  end

  def organization_name
    Organization.current.short_name
  end

  def is_referred
    return false if object.referrals.get_external_systems(external_system_name).last.nil?
    referral        = object.referrals.get_external_systems(external_system_name).last
    external_system = referral.external_system
    external_system&.token == context.uid
  end

  def referral_consent_form
    return [] unless object.referrals.get_external_systems(external_system_name).last.present? || is_referred
    referral = object.referrals.get_external_systems(external_system_name).last
    referral.consent_form.map do |attachment|
      asset_path(attachment.url)
    end
  end

  def reason_for_referral
    last_referral&.referral_reason || object.reason_for_referral || ''
  end

  def case_worker_name
    object.users.map(&:name).reject(&:blank?).join(', ')
  end

  def case_worker_mobile
    object.users.map(&:mobile).reject(&:blank?).join(', ')
  end

  def organization_address_code
    setting = Setting.cache_first
    return '' unless setting.province

    if setting.commune
      setting.commune.code
    elsif setting.district
      setting.district.code
    else
      setting.province.district.first.code
    end
  end

  def location_current_village_code
    object.village&.code || object.commune&.code || object.district&.code || object.province&.code || ""
  end

  def address_current_village_code
    object.village&.code || object.commune&.code || object.district&.code || object.province&.code || ""
  end

  def level_of_risk
    last_referral&.level_of_risk || ''
  end

  private

  def services
    related_services
  end

end
