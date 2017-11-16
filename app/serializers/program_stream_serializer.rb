class ProgramStreamSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :rules, :tracking_required, :enrollment, :exit_program, :quantity, :enrollable_client_ids
  has_many :trackings

  def enrollable_client_ids
    AdvancedSearches::ClientAdvancedSearch.new(object.rules, Client.all).filter.ids
  end
end
