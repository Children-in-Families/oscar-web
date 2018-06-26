module AdvancedSearches
  class SchoolGradeFields
    extend AdvancedSearchHelper

    def self.rule_field
      school_grade  = ['School Grade'].map { |item| drop_list_options('school_grade', format_header('school_grade'), Client::GRADES, format_header('basic_fields')) }
      school_grade
    end

    def self.client_field
      school_grade  = ['School Grade'].map { |item| drop_list_options('school_grade', format_header('school_grade'), school_grade_options, format_header('basic_fields')) }
      school_grade
    end

    private

    def self.school_grade_options
      grades = Client.where(school_grade: Client::GRADES)
      kindergartens = grades.where(school_grade: ['Kindergarten 1', 'Kindergarten 2', 'Kindergarten 3', 'Kindergarten 4']).pluck(:school_grade).uniq
      primary_grades = grades.where(school_grade: ('1'..'12').to_a).pluck(:school_grade).uniq.sort{ |x,y| x.to_i <=> y.to_i }
      years = grades.where(school_grade: ['Year 1', 'Year 2', 'Year 3', 'Year 4']).pluck(:school_grade).uniq
      [*kindergartens, *primary_grades, *years]
    end

    def self.drop_list_options(field_name, label, values, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        type: 'string',
        input: 'select',
        values: values,
        operators: ['equal', 'not_equal', 'is_empty', 'is_not_empty', 'between']
      }
    end
  end
end
