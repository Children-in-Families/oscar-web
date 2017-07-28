module AdvancedSearches
  class ColumnGenerator
    BUILDER_FIELDS = ['formbuilder', 'enrollment', 'tracking', 'exitprogram']

    def initialize(rules)
      @rules    = rules[:rules]
      @columns  = []
    end
    
    def generate
      @rules.each do |rule|
        field    = rule[:field]
        form_builder = field != nil ? field.split('_') : []
        if BUILDER_FIELDS.include? form_builder.first
          @columns << field
        elsif field != nil
          next
        else
          nested = AdvancedSearches::ColumnGenerator.new(rule).generate
          @columns << nested
        end
      end
      @columns.flatten
    end

  end
end