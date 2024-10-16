module PartnerAdvancedSearchesConcern
  extend ActiveSupport::Concern
  include ClientsHelper

  def advanced_search
    basic_rules  = JSON.parse @basic_filter_params
    $param_rules = nil
    $param_rules = find_params_advanced_search
    @partners    = AdvancedSearches::Partners::PartnerAdvancedSearch.new(basic_rules, Partner.all).filter
    custom_form_column
    respond_to do |f|
      f.html do
        @results                = @partner_grid.scope { |scope| scope.where(id: @partners.ids) }.assets.size
        @partner_grid.scope { |scope| scope.where(id: @partners.ids).page(params[:page]).per(20) }
      end
      f.xls do
        @partner_grid.scope { |scope| scope.where(id: @partners.ids).page(params[:page]).per(20) }
        form_builder_report
        send_data @partner_grid.to_xls, filename: "partner_report-#{Time.now}.xls"
      end
    end
  end

  def build_advanced_search
    @advanced_search = AdvancedSearch.new
  end

  def custom_form_column
    @custom_form_columns = custom_form_fields.group_by{ |field| field[:optgroup] }
  end

  def get_custom_form
    form_ids = CustomFieldProperty.where(custom_formable_type: 'Partner').pluck(:custom_field_id).uniq
    @custom_fields = CustomField.where(id: form_ids).order_by_form_title
  end

  def partner_builder_fields
    @builder_fields = get_partner_basic_fields + custom_form_fields
  end

  def get_partner_basic_fields
    AdvancedSearches::Partners::PartnerFields.new().render
  end

  def custom_form_values
    custom_form_value? ? eval(@advanced_search_params[:custom_form_selected]) : []
  end

  def custom_form_fields
    @custom_form_fields = get_custom_form_fields + get_has_this_form_fields
  end

  def get_custom_form_fields
    @custom_forms = AdvancedSearches::CustomFields.new(custom_form_values).render
  end

  def get_has_this_form_fields
    @has_this_form_fields = AdvancedSearches::HasThisFormFields.new(custom_form_values).render
  end

  def custom_form_value?
    @advanced_search_params.present? && @advanced_search_params[:custom_form_selected].present?
  end

  def has_params?
    @advanced_search_params.present? && @advanced_search_params[:basic_rules].present?
  end

  def find_params_advanced_search
    @advanced_search_params = params[:partner_advanced_search]
  end

  def basic_params
    @basic_filter_params  = @advanced_search_params[:basic_rules]
  end

  def form_builder_report
    @custom_form_fields.each do |field|
      fields = field[:id].split('__')
      @partner_grid.column(field[:id].to_sym, header: form_builder_format_header(fields)) do |client|
        if fields.last == 'Has This Form'
          custom_field_properties = client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Partner'}).count
        else
          format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
          custom_field_properties = client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Partner'}).properties_by(format_field_value)
          custom_field_properties.map{ |properties| format_properties_value(properties) }.join(' | ')
        end
      end
    end
  end
end
