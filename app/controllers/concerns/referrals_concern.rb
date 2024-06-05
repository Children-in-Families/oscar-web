module ReferralsConcern
  def find_external_system(external_name)
    ExternalSystem.find_by(name: external_name)&.name || ''
  end
end
