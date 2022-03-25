module CommunityAdvancedSearchConcern
  extend ActiveSupport::Concern
  include CommunityHelper

  def advanced_search
    basic_rules  = JSON.parse @basic_filter_params
    $param_rules = nil
    $param_rules = find_params_advanced_search
    @communities = AdvancedSearches::Communities::CommunityAdvancedSearch.new(basic_rules, Community.accessible_by(current_ability)).filter

    columns_visibility
    custom_form_columns

    respond_to do |f|
      f.html do
        @results = @community_grid.scope { |scope| scope.where(id: @communities.ids) }.assets.size
        @community_grid.scope { |scope| scope.where(id: @communities.ids).page(params[:page]).per(20) }
      end
      f.xls do
        @community_grid.scope { |scope| scope.where(id: @communities.ids) }
        custom_referral_data_report
        send_data @community_grid.to_xls, filename: "community_report-#{Time.now}.xls"
      end
    end
  end

  def build_advanced_search
    @advanced_search = AdvancedSearch.new
  end

  def custom_form_columns
    @custom_form_columns ||= custom_form_fields.group_by{ |field| field[:optgroup] } if params.dig(:community_advanced_search, :action_report_builder) == '#community-builder'
  end

  def list_custom_form
    form_ids = CustomFieldProperty.where(custom_formable_type: 'Community').pluck(:custom_field_id).uniq
    @list_custom_form ||= CustomField.where(id: form_ids).order_by_form_title
  end

  def community_builder_fields
    @builder_fields = community_basic_fields + custom_form_fields
    @builder_fields += quantitative_fields if quantitative_check?
  end

  def community_basic_fields
    AdvancedSearches::Communities::CommunityFields.new(user: current_user, pundit_user: pundit_user).render
  end

  def custom_form_values
    @custom_form_values ||= custom_form_value? ? eval(@advanced_search_params[:custom_form_selected]) : []
  end

  def custom_form_fields
    @custom_form_fields ||= custom_fields + this_form_fields
  end

  def this_form_fields
    @this_form_fields ||= AdvancedSearches::HasThisFormFields.new(custom_form_values, 'Community').render
  end

  def custom_fields
    @custom_fields ||= AdvancedSearches::CustomFields.new(custom_form_values, 'Community').render
  end

  def quantitative_fields
    quantitative_fields = AdvancedSearches::QuantitativeCaseFields.new(current_user, 'community')
    @quantitative_fields ||= quantitative_fields.render
  end

  def custom_form_value?
    @advanced_search_params.present? && @advanced_search_params[:custom_form_selected].present?
  end

  def has_params?
    @advanced_search_params.present? && @advanced_search_params[:basic_rules].present?
  end

  def quantitative_check?
    @advanced_search_params.present? && @advanced_search_params[:quantitative_check].present?
  end

  def find_params_advanced_search
    Rails.cache.fetch(user_cache_id << "find_params_advanced_search") do
      @advanced_search_params = params[:community_advanced_search]
    end

  end

  def basic_params
    @basic_filter_params = @advanced_search_params[:basic_rules]
  end

  def form_builder_report
    @custom_form_fields.each do |field|
      fields = field[:id].split('__')
      @community_grid.column(field[:id].to_sym, header: form_builder_format_header(fields)) do |community|
        if fields.last == 'Has This Form'
          community.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Community' }).count
        else
          format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
          custom_field_properties = community.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Community' }).properties_by(format_field_value)
          custom_field_properties.map { |properties| format_properties_value(properties) }.join(' | ')
        end
      end
    end
  end
end
