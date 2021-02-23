module CommunityHelper
  def community_grid_columns(grid)
    @community_grid_columns ||= grid.columns.map(&:name).map { |column_name| [column_name, Community.human_attribute_name(column_name)] }.to_h
  end

  def community_columns_visibility(column)
    @community_grid_columns[column]
  end
end
