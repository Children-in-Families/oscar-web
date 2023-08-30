class CommunityColumnsVisibility
  def initialize(grid, params)
    @grid   = grid
    @params = params
  end

  def columns_collection
    @grid.columns.map(&:name).map { |column| ["#{column}_".to_sym, column]  }.to_h
  end

  def visible_columns
    @grid.column_names = []
    community_default_columns = Setting.cache_first.community_default_columns
    
    params = @params.keys.select { |k| k.match(/\_$/) }
    if params.present? && community_default_columns.present?
      defualt_columns = params - community_default_columns
    else
      if params.present?
        defualt_columns = params
      else
        defualt_columns = community_default_columns
      end
    end
    add_custom_builder_columns.each do |key, value|
      @grid.column_names << value if community_default(key, defualt_columns) || @params[key]
    end
  end

  private

  def add_custom_builder_columns
    columns = columns_collection
    if @params[:column_form_builder].present?
      @params[:column_form_builder].each do |column|
        field   = column['id']
        columns = columns.merge!("#{field}_": field.to_sym)
      end
    end
    columns
  end

  def community_default(column, setting_community_default_columns)
    return false if setting_community_default_columns.nil?

    setting_community_default_columns.include?(column.to_s) if @params.dig(:community_grid, :descending).present? || (@params[:community_advanced_search].present? && @params.dig(:community_grid, :descending).present?) || @params[:community_grid].nil? || @params[:community_advanced_search].nil?
  end
end
