module AdvancedSearches
  module Partners
    class PartnerBaseSqlBuilder
      BLANK_FIELDS = ['start_date', 'organization_type_id', 'id']
      SENSITIVITY_FIELDS = %w(name contact_person_name address email contact_person_mobile engagement affiliation background)

      def initialize(partners, rules)
        @partners     = partners
        @values      = []
        @sql_string  = []
        @condition    = rules['condition']
        @basic_rules  = rules['rules'] || []

        @columns_visibility = []
      end

      def generate
        @basic_rules.each do |rule|
          field    = rule['field']
          operator = rule['operator']
          value    = rule['value']
          form_builder = field != nil ? field.split('__') : []
          if form_builder.first == 'formbuilder'
            if form_builder.last == 'Has This Form'
              custom_form_value = CustomField.find_by(form_title: value, entity_type: 'Partner').try(:id)
              @sql_string << "Partners.id IN (?)"
              @values << @partners.joins(:custom_fields).where('custom_fields.id = ?', custom_form_value).uniq.ids
            else
              custom_form = CustomField.find_by(form_title: form_builder.second, entity_type: 'Partner')
              custom_field = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rule, 'partner').get_sql
              @sql_string << custom_field[:id]
              @values << custom_field[:values]
            end

          elsif field != nil
            base_sql(field, operator, value)
          else
            nested_query =  AdvancedSearches::Partners::PartnerBaseSqlBuilder.new(@partners, rule).generate
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
            @sql_string << "lower(partners.#{field}) = ?"
            @values << value.downcase.squish
          else
            @sql_string << "partners.#{field} = ?"
            @values << value
          end

        when 'not_equal'
          if SENSITIVITY_FIELDS.include?(field)
            @sql_string << "lower(partners.#{field}) != ?"
            @values << value.downcase.squish
          else
            @sql_string << "partners.#{field} != ?"
            @values << value
          end

        when 'less'
          @sql_string << "partners.#{field} < ?"
          @values << value

        when 'less_or_equal'
          @sql_string << "partners.#{field} <= ?"
          @values << value

        when 'greater'
          @sql_string << "partners.#{field} > ?"
          @values << value

        when 'greater_or_equal'
          @sql_string << "partners.#{field} >= ?"
          @values << value

        when 'contains'
          @sql_string << "partners.#{field} ILIKE ?"
          @values << "%#{value.squish}%"

        when 'not_contains'
          @sql_string << "partners.#{field} NOT ILIKE ?"
          @values << "%#{value.squish}%"

        when 'is_empty'
          if BLANK_FIELDS.include? field
            @sql_string << "partners.#{field} IS NULL"
          else
            @sql_string << "(partners.#{field} IS NULL OR partners.#{field} = '')"
          end

        when 'is_not_empty'
          if BLANK_FIELDS.include? field
            @sql_string << "partners.#{field} IS NOT NULL"
          else
            @sql_string << "(partners.#{field} IS NOT NULL AND partners.#{field} != '')"
          end

        when 'between'
          @sql_string << "partners.#{field} BETWEEN ? AND ?"
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
