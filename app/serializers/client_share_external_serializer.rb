class ClientShareExternalSerializer < ActiveModel::Serializer
  include OrganizationSerializerConcern

  attributes  :given_name, :family_name, :local_given_name, :local_family_name, :gender,
              :date_of_birth, :global_id, :slug, :external_id, :external_id_display,
              :mosvy_number, :location_current_village_code, :case_worker_name, :case_worker_mobile,
              :is_referred, :organization_name, :organization_address_code, :resource, :services


  def organization_name
    Organization.current.short_name
  end

  def location_current_village_code
    object.village_code || object.commune_code || object.district_code || ""
  end

  def external_id
    object.external_id || ""
  end

  def external_id_display
    object.external_id_display || ""
  end

  def mosvy_number
    object.mosvy_number || ""
  end

  def case_worker_name
    object.users.map(&:name).reject(&:blank?).join(", ")
  end

  def case_worker_mobile
    object.users.map(&:mobile).reject(&:blank?).join(", ")
  end

  def is_referred
    return false if object.referrals.get_external_systems(external_system_name).last.nil?
    referral        = object.referrals.get_external_systems(external_system_name).last
    external_system = referral.external_system
    external_system&.token == context.uid
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

  private

  def resource
    return 'primero' if external_id.present?
  end

  def services
    return related_services if external_id.present?

    []
  end

end
