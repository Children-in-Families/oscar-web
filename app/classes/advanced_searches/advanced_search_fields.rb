module AdvancedSearch
  class AdvancedSearchFields
    attr_reader :header_group, :number_fields, :text_fields, :date_picker_fields, :drop_list_options

    def initialize(header_group=[], number_fields=[], text_fields=[], date_picker_fields=[], drop_list_fields=[])
      @header_group = header_group
      @number_fields = number_fields
      @text_fields = text_fields
      @date_picker_fields = date_picker_fields
      @drop_list_options = drop_list_options
    end

    def render
      group                 = header_translation('basic_fields')
      number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, header_translation(item), group) }
      text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, header_translation(item), group) }
      date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, header_translation(item), group) }
      drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, header_translation(item.first), item.last, group) }

      search_fields         = text_fields + drop_list_fields + number_fields + date_picker_fields

      search_fields.sort_by { |f| f[:label].downcase }
    end

    private

    def number_type_list
      ['significant_family_member_count', 'household_income', 'female_children_count', 'male_children_count', 'female_adult_count', 'male_adult_count', 'id']
    end

    def text_type_list
      ['code', 'name', 'caregiver_information', 'case_history', 'street', 'house']
    end

    def date_type_list
      ['contract_date']
    end

    def drop_down_type_list
      [
        ['family_type', family_type_options],
        ['status', status_options],
        ['province_id', provinces],
        ['district_id', districts],
        ['dependable_income', { yes: 'Yes', no: 'No' }],
        ['client_id', clients],
        ['commune_id', communes],
        ['village_id', villages]
      ]
    end

    def header_translation(group)

    end
  end
end
