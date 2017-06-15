class ProgramStreamSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :rules, :enrollment, :exit_program, :frequency, :time_of_frequency, :quantity, :enrollable_client_ids
  has_many :trackings

  def enrollable_client_ids
    AdvancedSearches::ClientAdvancedSearch.new(object.rules, {}, Client.all).filter.ids
  end
end

