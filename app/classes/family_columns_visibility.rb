class FamilyColumnsVisibility
  def initialize(grid, params)
    @grid   = grid
    @params = params
  end

  def columns_collection
    {
      name_: :name,
      code_: :code,
      id_: :id,
      family_type_: :family_type,
      case_history_: :case_history,
      address_: :address,
      member_count_: :member_count,
      caregiver_information_: :caregiver_information,
      household_income_: :household_income,
      dependable_income_: :dependable_income,
      case_worker_: :case_worker,
      significant_family_member_count_: :significant_family_member_count,
      contract_date_: :contract_date,
      province_id_: :province,
      manage_: :manage,
      changelog_: :changelog,
      clients_: :cases,
      case_workers_: :case_workers,
      female_children_count_: :female_children_count,
      male_children_count_: :male_children_count,
      female_adult_count_: :female_adult_count,
      male_adult_count_: :male_adult_count
    }
  end

  def visible_columns
    @grid.column_names = []
    family_default_columns = Setting.first.try(:family_default_columns)
    params = @params.keys.select{ |k| k.match(/\_$/) }
    if params.present? && family_default_columns.present?
      defualt_columns = params - family_default_columns
    else
      if params.present?
        defualt_columns = params
      else
        defualt_columns = family_default_columns
      end
    end
    add_custom_builder_columns.each do |key, value|
      @grid.column_names << value if family_default(key, defualt_columns) || @params[key]
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

  def family_default(column, setting_family_default_columns)
    return false if setting_family_default_columns.nil?
    setting_family_default_columns.include?(column.to_s) if @params.dig(:family_grid, :descending).present? || (@params[:family_advanced_search].present? && @params.dig(:family_grid, :descending).present?) || @params[:family_grid].nil? || @params[:family_advanced_search].nil?
  end
end
