module CallHelper
  def call_report_builder_fields
    args = group_call_field_types
    call_builder_fields = AdvancedSearches::AdvancedSearchFields.new(args)
  end

  def group_call_field_types
    translations = @calls_grid.datagrid_attributes[2..-1].map do |header|
      [header, I18n.t("datagrid.columns.partners.#{header.to_s}")]
    end.to_h

    number_fields = []; text_fields = []; date_picker_fields = []; dropdown_list_options = []

    @calls_grid.filters.zip(@calls_grid.header).each do |filter, header_name|
      field_name = header_name.parameterize.underscore
      case filter.class.name
      when /integerfilter/i
        number_fields << field_name
      when /defaultfilter/i
        text_fields << field_name
      when /datefilter/i
        date_picker_fields << field_name
      when /enumfilter/i
        dropdown_list_options << field_name
      end
    end

    {
      translation: translations, number_field: number_fields,
      text_field: text_fields, date_picker_field: date_picker_fields,
      dropdown_list_option: get_dropdown_list(dropdown_list_options)
    }
  end

  def get_dropdown_list(dropdown_list_options)
    dropdown_list_options.map do |field_name|
      [field_name, self.send(field_name.to_sym)]
    end
  end

  def referee
    Referee.pluck(:name, :id)
  end

  def receiving_staff
    User.case_workers.map { |user| [user.name, user.id] }
  end
end
