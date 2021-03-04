module AdvancedSearches
  class QuantitativeCaseFields
    include AdvancedSearchHelper

    attr_reader :visible_on
    def initialize(user, visible_on = 'client')
      @user = user
      @visible_on = visible_on
    end

    def render
      opt_group = format_header('quantitative')
      if @user.admin? || @user.strategic_overviewer?
        quantitative_types = QuantitativeType.includes(:quantitative_cases).where('quantitative_types.visible_on LIKE ?', "%#{visible_on}%")
      else
        quantitative_type_ids = @user.quantitative_type_permissions.readable.pluck(:quantitative_type_id)
        quantitative_types = QuantitativeType.includes(:quantitative_cases).where(id: quantitative_type_ids)
      end
      quantitative_cases = quantitative_types.map do |qt|
        AdvancedSearches::FilterTypes.drop_list_options(
          "quantitative__#{qt.id}",
          qt.name,
          quantitative_cases(qt),
          opt_group
        )
      end

      quantitative_cases.sort_by { |f| f[:label].downcase }
    end

    private

    def quantitative_cases(qt)
      qt.quantitative_cases.map{ |qc| { qc.id.to_s => qc.value }}
    end
  end
end
