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
      case_workers_: :case_workers
    }
  end

  def visible_columns
    @grid.column_names = []
    add_custom_builder_columns.each do |key, value|
      @grid.column_names << value if @params[key]
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
end
