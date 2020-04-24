class OrganizationClientSerializer < ActiveModel::Serializer
  attributes :global_id, :external_id, :external_id_display, :mosvy_number, :mosvy_number, :given_name, :family_name,
             :gender, :date_of_birth, :location_current_village_code, :address_current_village_code, :reason_for_referral,
             :organization_id, :organization_name, :external_case_worker_name, :external_case_worker_id, :protection_status,
             :services, :status, :case_worker_name, :case_worker_mobile

  def global_id
    object.global_identity&.ulid
  end

  def organization_id
    Organization.current.id
  end

  def organization_name
    Organization.current.short_name
  end

  def services
    object.program_streams.joins(:services).distinct.map{ |ps| ps.services.map{ |service| { id: service.id, uuid: service.uuid, name: service.name } } }.compact.flatten.uniq
  end

  def case_worker_name
    object.users.map(&:name).reject(&:blank?).join(", ")
  end

  def case_worker_mobile
    object.users.map(&:mobile).reject(&:blank?).join(", ")
  end

  def location_current_village_code
    object.village&.code || ""
  end

  def address_current_village_code
    object.village&.code || ""
  end

  def protection_status
    object.reason_for_referral
  end
end
