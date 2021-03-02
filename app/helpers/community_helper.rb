module CommunityHelper
  def community_grid_columns
    column_names = %i[id name name_en gender role status phone_number received_by_id initial_referral_date referral_source_id referral_source_category_id formed_date province_id district_id commune_id village_id representative_name user_id]
    @community_grid_columns ||= column_names.map { |column_name| [column_name, I18n.t("activerecord.attributes.community.#{column_name}")] }.to_h
  end

  def community_columns_visibility(column)
    @community_grid_columns[column]
  end

  def default_community_columns_visibility(column)
    @community_grid_columns || community_grid_columns
    label_tag "#{column}_", @community_grid_columns[column.gsub('_', '').to_sym]
  end

  def selected_commuity_column(field_key)
    default_setting(field_key, @community_default_columns) || params[field_key.to_sym].present?
  end

  def get_community_rule(params, field)
    return unless params.dig('community_advanced_search').present? && params.dig('community_advanced_search', 'basic_rules').present?
    base_rules = eval params.dig('community_advanced_search', 'basic_rules')
    rules = base_rules.dig(:rules) if base_rules.presence

    index = find_rules_index(rules, field) if rules.presence

    rule  = rules[index] if index.presence
  end
end
