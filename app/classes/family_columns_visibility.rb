class FamilyColumnsVisibility
  include FamiliesHelper

  def initialize(grid, params)
    @grid = grid
    @params = params
  end

  def columns_collection
    map_family_field_labels.keys.map { |family_label_key| ["#{family_label_key}_".to_sym, family_label_key] }.to_h
  end

  def visible_columns
    @grid.column_names = []
    family_default_columns = Setting.first.try(:family_default_columns)
    params = @params.keys.select { |k| k.match(/\_$/) }
    if params.present? && family_default_columns.present?
      defualt_columns = params - family_default_columns
    else
      if params.present?
        defualt_columns = params
      else
        defualt_columns = family_default_columns
      end
    end
    domain_score_columns.each do |key, value|
      @grid.column_names << value if family_default(key, defualt_columns) || @params[key]
    end
    add_custom_builder_columns.each do |key, value|
      @grid.column_names << value if family_default(key, defualt_columns) || @params[key]
    end
  end

  private

  def domain_score_columns
    columns = columns_collection
    Domain.family_custom_csi_domains.order_by_identity.each do |domain|
      identity = domain.identity
      field = domain.convert_custom_identity
      columns = columns.merge!("#{field}_": field.to_sym)
    end
    columns
  end

  def add_custom_builder_columns
    columns = quantitative_type_columns
    if @params[:column_form_builder].present?
      @params[:column_form_builder].each do |column|
        field = column['id']
        columns = columns.merge!("#{field}_": field.to_sym)
      end
    end
    columns
  end

  def family_default(column, setting_family_default_columns)
    return false if setting_family_default_columns.nil?
    setting_family_default_columns.include?(column.to_s) if @params.dig(:family_grid, :descending).present? || (@params[:family_advanced_search].present? && @params.dig(:family_grid, :descending).present?) || @params[:family_grid].nil? || @params[:family_advanced_search].nil?
  end

  def quantitative_type_columns
    columns = columns_collection
    QuantitativeType.joins(:quantitative_cases).where('quantitative_types.visible_on LIKE ?', '%family%').uniq.each do |quantitative_type|
      field = quantitative_type.name
      columns = columns.merge!("#{field}_": field.to_sym)
    end
    columns
  end
end
