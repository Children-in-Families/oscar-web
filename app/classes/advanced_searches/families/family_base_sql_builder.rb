module AdvancedSearches
  module Families
    class FamilyBaseSqlBuilder
      ASSOCIATION_FIELDS = ['client_id', 'case_workers']
      BLANK_FIELDS = %w(contract_date household_income dependable_income female_children_count male_children_count female_adult_count male_adult_count province_id significant_family_member_count district_id commune_id village_id id)
      SENSITIVITY_FIELDS = %w(name code address case_history caregiver_information family_type status)

      def initialize(families, rules)
        @families = families
        @values = []
        @sql_string = []
        @condition = rules['condition']
        @basic_rules = rules['rules'] || []

        @columns_visibility = []
      end

      def generate
        @basic_rules.each do |rule|
          field    = rule['id']
          operator = rule['operator']
          value    = rule['value']
          form_builder = field != nil ? field.split('__') : []
          if ASSOCIATION_FIELDS.include?(field)
            association_filter = AdvancedSearches::Families::FamilyAssociationFilter.new(@families, field, operator, value).get_sql
            @sql_string << association_filter[:id]
            @values     << association_filter[:values]

          elsif form_builder.first == 'formbuilder'
            if form_builder.last == 'Has This Form'
              custom_form_value = CustomField.find_by(form_title: value, entity_type: 'Family').try(:id)
              @sql_string << "Families.id IN (?)"
              @values << @families.joins(:custom_fields).where('custom_fields.id = ?', custom_form_value).uniq.ids
            else
              custom_form = CustomField.find_by(form_title: form_builder.second, entity_type: 'Family')
              custom_field = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rule, 'family').get_sql
              @sql_string << custom_field[:id]
              @values << custom_field[:values]
            end
          elsif field != nil
            base_sql(field, operator, value)
          else
            nested_query =  AdvancedSearches::Families::FamilyBaseSqlBuilder.new(@families, rule).generate
            @sql_string << nested_query[:sql_string]
            nested_query[:values].select{ |v| @values << v }
          end
        end

        @sql_string = @sql_string.join(" #{@condition} ")
        @sql_string = "(#{@sql_string})" if @sql_string.present?
        { sql_string: @sql_string, values: @values }
      end

      private

      def base_sql(field, operator, value)
        case operator
        when 'equal'
          if SENSITIVITY_FIELDS.include?(field)
            @sql_string << "lower(families.#{field}) = ?"
            @values << value.downcase.squish
          else
            @sql_string << "families.#{field} = ?"
            @values << value
          end

        when 'not_equal'
          if SENSITIVITY_FIELDS.include?(field)
            @sql_string << "lower(families.#{field}) != ?"
            @values << value.downcase.squish
          elsif BLANK_FIELDS.include? field
            @sql_string << "(families.#{field} IS NULL OR families.#{field} != ?)"
            @values << value
          else
            @sql_string << "families.#{field} != ?"
            @values << value
          end

        when 'less'
          @sql_string << "families.#{field} < ?"
          @values << value

        when 'less_or_equal'
          @sql_string << "families.#{field} <= ?"
          @values << value

        when 'greater'
          @sql_string << "families.#{field} > ?"
          @values << value

        when 'greater_or_equal'
          @sql_string << "families.#{field} >= ?"
          @values << value

        when 'contains'
          @sql_string << "families.#{field} ILIKE ?"
          @values << "%#{value.squish}%"

        when 'not_contains'
          @sql_string << "families.#{field} NOT ILIKE ?"
          @values << "%#{value.squish}%"

        when 'is_empty'
          if BLANK_FIELDS.include? field
            @sql_string << "families.#{field} IS NULL"
          else
            @sql_string << "(families.#{field} IS NULL OR families.#{field} = '')"
          end

        when 'is_not_empty'
          if BLANK_FIELDS.include? field
            @sql_string << "families.#{field} IS NOT NULL"
          else
            @sql_string << "(families.#{field} IS NOT NULL AND families.#{field} != '')"
          end

        when 'between'
          @sql_string << "families.#{field} BETWEEN ? AND ?"
          @values << value.first
          @values << value.last
        end
      end

      def validate_integer(values)
        if values.is_a?(Array)
          first_value = values.first.to_i > 1000000 ? "1000000" : values.first
          last_value  = values.last.to_i > 1000000 ? "1000000" : values.last
          [first_value, last_value]
        else
          values.to_i > 1000000 ? "1000000" : values
        end
      end
    end
  end
end
