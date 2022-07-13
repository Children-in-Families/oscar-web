module OrganizationSerializerConcern
  def related_services
    service_types = object.program_streams.joins(:services).distinct.map do |ps|
      enrollment_date = object.client_enrollments.where(program_stream_id: ps.id).first&.enrollment_date&.to_s
      ps.services.map do |service|
        {
          program_name: ps.name,
          enrollment_date: enrollment_date,
          uuid: service.uuid,
          name: service.name,
          referral_id: object.id
        }
      end
    end.compact.flatten.uniq

    Service.where(id: list_referrals.map(&:service_ids).flatten || []).map do |service|
      service_types << {
        program_name: nil,
        enrollment_date: nil,
        uuid: service.uuid,
        name: service.name,
        referral_id: object.id
      }
    end
    service_types
  end

  private

  def external_system_name
    ExternalSystem.find_by(token: context.email)&.name || ''
  end

  def last_referral
    object.referrals.get_external_systems(external_system_name).last
  end

  def list_referrals
    object.referrals.get_external_systems(external_system_name)
  end
end
