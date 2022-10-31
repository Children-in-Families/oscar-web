module AdvancedSearches
  class CommonFields

    include AdvancedSearchHelper

    def initialize(program_ids = nil, assessment_checked = false)
      @program_ids = program_ids
      @assessment_checked = assessment_checked

      address_translation
    end

    def render
      common_group = format_header('common_searches')

      date_picker_fields = @program_ids.nil? ? [] : common_search_date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), common_group) }
      drop_down_fields = @assessment_checked ? common_search_dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, common_group) } : []

      results = date_picker_fields + drop_down_fields

      results.sort_by { |f| f[:label].downcase }
    end

    def common_search_date_type_list
      ['active_client_program']
    end

    def common_search_dropdown_list
      better_same_worse_options = { better: 'Better', same: 'The same', worse: 'Worse' }
      [
        ['assessment_condition_last_two', better_same_worse_options],
        ['assessment_condition_first_last', better_same_worse_options]
      ]
    end
  end
end
