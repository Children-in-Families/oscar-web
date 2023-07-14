module AdvancedSearches
  class AdvancedSearchFields
    attr_reader :group_label, :translations, :number_type_list, :text_type_list, :date_type_list, :dropdown_type_list

    def initialize(group_label, args)
      @group_label         = group_label
      @translations        = args.fetch(:translation)
      @text_type_list      = args.fetch(:text_field)
      @date_type_list      = args.fetch(:date_picker_field)
      @number_type_list    = args.fetch(:number_field)
      @dropdown_type_list = args.fetch(:dropdown_list_option)
    end

    def render
      group                 = header_translation(group_label)
      number_fields         = number_type_list.map { |item| AdvancedSearches::QueryFieldType.number_options(item, header_translation(item), group) }
      text_fields           = text_type_list.map { |item| AdvancedSearches::QueryFieldType.text_options(item, header_translation(item), group) }
      date_picker_fields    = date_type_list.map { |item| AdvancedSearches::QueryFieldType.date_picker_options(item, header_translation(item), group) }
      drop_list_fields      = dropdown_type_list.map { |item| AdvancedSearches::QueryFieldType.drop_list_options(item.first, header_translation(item.first), item.last, group) }
      search_fields         = text_fields + drop_list_fields + number_fields + date_picker_fields

      search_fields.sort_by { |f| f[:label].downcase }
    end

    private

    def header_translation(key)
      translations[key.to_sym] || ''
    end
  end
end
