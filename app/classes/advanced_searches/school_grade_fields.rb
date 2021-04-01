module AdvancedSearches
  class SchoolGradeFields
    extend AdvancedSearchHelper

    def self.render
      school_grade  = ['School Grade'].map { |item| drop_list_options('school_grade', format_header('school_grade'), school_grade_options, format_header('basic_fields')) }
      school_grade
    end

    private

    def self.drop_list_options(field_name, label, values, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        field: label,
        type: 'string',
        input: 'select',
        values: values,
        data: { values: values },
        operators: ['equal', 'not_equal', 'is_empty', 'is_not_empty', 'between']
      }
    end

    def self.school_grade_options
      current_translations = I18n.t('advanced_search.fields.school_grade_list')
      Client::GRADES.map do|s|
        translations = I18n.backend.send(:translations)[:en][:advanced_search][:fields]
        key = translations[:school_grade_list].key(s.to_i > 0 ? s.to_i : s)
        { s => current_translations[key] }
      end
    end
  end
end
