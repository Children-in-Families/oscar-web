module CallHelper
  def call_report_builder_fields
    args = group_call_field_types
    call_builder_fields = AdvancedSearches::AdvancedSearchFields.new(args)
  end

  def group_call_field_types
    translations = @calls_grid.datagrid_attributes[2..-1].map do |header|
      [header, I18n.t("datagrid.columns.partners.#{header.to_s}")]
    end.to_h

    number_fields = []; text_fields = []; date_picker_fields = []; drop_list_options = []

    @calls_grid.filters.each do |filter|
      case filter.class.name
      when /integerfilter/i
        number_fields << filter.name
      when /defaultfilter/i
        text_fields << filter.name
      when /datefilter/i
        date_picker_fields << filter.name
      when /enumfilter/i
        drop_list_options << filter.name
      end
    end
    { translation: translations, number_field: number_fields, text_field: text_fields, date_picker_field: date_picker_fields, drop_list_option: drop_list_options }
  end
end
