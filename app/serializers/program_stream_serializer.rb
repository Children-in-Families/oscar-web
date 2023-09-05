class ProgramStreamSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :rules, :tracking_required, :enrollment, :exit_program, :quantity, :program_exclusive, :mutual_dependence, :enrollable_client_ids
  has_many :trackings

  def enrollable_client_ids
    if object.rules.present?
      clients, _query = AdvancedSearches::ClientAdvancedSearch.new(object.rules, Client.all).filter
      clients.ids
    end
  end
end
