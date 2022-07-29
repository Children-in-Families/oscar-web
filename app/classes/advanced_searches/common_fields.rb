module AdvancedSearches
  class CommonFields

    include AdvancedSearchHelper

    def initialize(program_ids)
      @program_ids = program_ids

      address_translation
    end

    def render
      date_picker_fields  = common_search_date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), format_header('common_searches')) }

      results = date_picker_fields

      results.sort_by { |f| f[:label].downcase }
    end

    def common_search_date_type_list
      ['active_client_program']
    end
  end
end
