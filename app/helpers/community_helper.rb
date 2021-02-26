module CommunityHelper
  def community_grid_columns(grid)
    @community_grid_columns ||= grid.columns.map(&:name).map { |column_name| [column_name, I18n.t("activerecord.attributes.community.#{column_name}")] }.to_h
  end

  def community_columns_visibility(column)
    @community_grid_columns[column]
  end

  def default_community_columns_visibility(column)
    label_tag "#{column}_", @community_grid_columns[column.gsub('_', '').to_sym]
  end
end
