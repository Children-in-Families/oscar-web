module AdvancedSearches
  class QuantitativeCaseFields
    extend AdvancedSearchHelper


    def self.render
      opt_group = format_header('quantitative')
      quantitative_cases = QuantitativeType.all.map do |qt|
        AdvancedSearches::FilterTypes.drop_list_options(
          "quantitative_#{qt.id}",
          qt.name,
          quantitative_cases(qt),
          opt_group
          )
      end

      quantitative_cases.sort_by { |f| f[:label].downcase }
    end

    private
    def self.quantitative_cases(qt)
      qt.quantitative_cases.map{ |qc| { qc.id.to_s => qc.value }}
    end
  end
end
