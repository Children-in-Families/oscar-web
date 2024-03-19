class PartnerColumnsVisibility
  def initialize(grid, params)
    @grid = grid
    @params = params
  end

  def columns_collection
    {
      name_: :name,
      id_: :id,
      contact_person_name_: :contact_person_name,
      contact_person_email_: :contact_person_email,
      contact_person_mobile_: :contact_person_mobile,
      address_: :address,
      organization_type_: :organization_type,
      province_id_: :province,
      engagement_: :engagement,
      background_: :background,
      start_date_: :start_date,
      changelog_: :changelog,
      manage_: :manage
    }
  end

  def visible_columns
    @grid.column_names = []
    partner_default_columns = Setting.first.try(:partner_default_columns)
    params = @params.keys.select { |k| k.match(/\_$/) }
    if params.present? && partner_default_columns.present?
      defualt_columns = params - partner_default_columns
    else
      if params.present?
        defualt_columns = params
      else
        defualt_columns = partner_default_columns
      end
    end
    add_custom_builder_columns.each do |key, value|
      @grid.column_names << value if partner_default(key, defualt_columns) || @params[key]
    end
  end

  private

  def add_custom_builder_columns
    columns = columns_collection
    if @params[:column_form_builder].present?
      @params[:column_form_builder].each do |column|
        field = column['id']
        columns = columns.merge!("#{field}_": field.to_sym)
      end
    end
    columns
  end

  def partner_default(column, setting_partner_default_columns)
    return false if setting_partner_default_columns.nil?
    setting_partner_default_columns.include?(column.to_s) if @params.dig(:partner_grid, :descending).present? || (@params[:partner_advanced_search].present? && @params.dig(:partner_grid, :descending).present?) || @params[:partner_grid].nil? || @params[:partner_advanced_search].nil?
  end
end
