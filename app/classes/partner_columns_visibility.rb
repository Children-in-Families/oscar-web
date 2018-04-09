class PartnerColumnsVisibility
  def initialize(grid, params)
    @grid   = grid
    @params = params
  end

  def columns_collection
    {
      name_:                                     :name,
      id_:                                       :id,
      contact_person_name_:                      :contact_person_name,
      contact_person_email_:                     :contact_person_email,
      contact_person_mobile_:                    :contact_person_mobile,
      address_:                                  :address,
      organisation_type_:                        :organisation_type,
      affiliation_:                              :affiliation,
      province_id_:                              :province_id,
      engagement_:                               :engagement,
      background_:                               :background,
      start_date_:                               :start_date,
      changelog_:                                :changelog,
      manage_:                                   :manage,
    }
  end

  def visible_columns
    @grid.column_names = []
    partner_default_columns = Setting.first.try(:partner_default_columns)
    add_custom_builder_columns.each do |key, value|
      @grid.column_names << value if partner_default(value, partner_default_columns) || @params[key]
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

  def partner_default(column, setting_partner_default_columns)
    return false if setting_partner_default_columns.nil?
    setting_partner_default_columns.include?(column.to_s) unless @params[:partner_grid].present? || @params[:partner_advanced_search].present?
  end
end
