class ProgramStreamSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :rules, :tracking_required, :enrollment, :exit_program, :quantity,
             :program_exclusive, :mutual_dependence, :enrollable_client_ids, :completed, :entity_type,
             :maximum_client, :program_permission_editable, :internal_referral_user_ids

  has_many :trackings
  has_many :services

  private

  def enrollable_client_ids
    if object.rules.present?
      clients, _query = AdvancedSearches::ClientAdvancedSearch.new(object.rules, Client.all).filter
      clients.ids
    end
  end

  def maximum_client
    object.quantity.present? && object.client_enrollments.active.size >= object.quantity
  end

  def program_permission_editable
    scope.current_user.program_stream_permissions.find_by(program_stream_id: object.id).try(:editable)
  end
end
