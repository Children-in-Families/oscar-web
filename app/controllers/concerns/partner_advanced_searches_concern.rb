module PartnerAdvancedSearchesConcern
  extend ActiveSupport::Concern
  include ClientsHelper

  def advanced_search
    basic_rules          = JSON.parse @basic_filter_params
    @partners            = AdvancedSearches::Partners::PartnerAdvancedSearch.new(basic_rules, Partner.all).filter
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
    @custom_form_columns = get_custom_form_fields.group_by{ |field| field[:optgroup] }
  end
  def get_custom_form
    @custom_fields  = CustomField.joins(:custom_field_properties).partner_forms.order_by_form_title.uniq
  end

  def partner_builder_fields
    @builder_fields = get_partner_basic_fields + get_custom_form_fields
  end

  def get_partner_basic_fields
    AdvancedSearches::Partners::PartnerFields.new().render
  end

  def custom_form_values
    custom_form_value? ? eval(@advanced_search_params[:custom_form_selected]) : []
  end

  def get_custom_form_fields
    @custom_form_fields = AdvancedSearches::CustomFields.new(custom_form_values).render
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
      fields = field[:id].split('_')
      @partner_grid.column(field[:id].to_sym, header: form_builder_format_header(fields)) do |client|
        format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        custom_field_properties = client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Partner'}).properties_by(format_field_value)
        custom_field_properties.map{ |properties| format_properties_value(properties) }.join(' | ')
      end
    end
  end
end
