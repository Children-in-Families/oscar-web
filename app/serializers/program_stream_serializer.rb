class ProgramStreamSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :rules, :tracking_required, :enrollment, :exit_program, :quantity,
             :program_exclusive, :mutual_dependence, :enrollable_client_ids, :completed, :entity_type,
             :maximum_client, :program_permission_editable, :internal_referral_user_ids, :trackings, :services

  private

  def trackings
    Rails.cache.fetch([Apartment::Tenant.current, 'trackings', 'ProgramStream', object.id]) do
      ActiveModel::ArraySerializer.new(object.trackings.visible, each_serializer: TrackingSerializer)
    end
  end

  def services
    Rails.cache.fetch([Apartment::Tenant.current, 'services', 'ProgramStream', object.id]) do
      ActiveModel::ArraySerializer.new(object.services, each_serializer: ServiceSerializer)
    end
  end

  def enrollable_client_ids
    return [] unless object.rules.present?

    Rails.cache.fetch([Apartment::Tenant.current, 'enrollable_client_ids', 'ProgramStream', 'User', object.id, scope.current_user.id]) do
      clients, _query = AdvancedSearches::ClientAdvancedSearch.new(object.rules, Client.accessible_by(scope.current_ability)).filter
      clients.ids
    end
  end

  def maximum_client
    Rails.cache.fetch([Apartment::Tenant.current, 'maximum_client', 'ProgramStream', object.id]) do
      object.quantity.present? && object.client_enrollments.active.size >= object.quantity
    end
  end

  def program_permission_editable
    Rails.cache.fetch([Apartment::Tenant.current, 'program_permission_editable', 'ProgramStream', 'User', object.id, scope.current_user.id]) do
      scope.current_user.program_stream_permissions.find_by(program_stream_id: object.id).try(:editable)
    end
  end
end
