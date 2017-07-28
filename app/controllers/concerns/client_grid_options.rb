module ClientGridOptions
  include ClientsHelper
  def choose_grid
    if current_user.admin? || current_user.strategic_overviewer?
      admin_client_grid
    elsif current_user.case_worker? || current_user.any_manager?
      non_admin_client_grid
    end
  end

  def columns_visibility
    @client_columns ||= ClientColumnsVisibility.new(@client_grid, params.merge(column_form_builder: column_form_builder))
    @client_columns.visible_columns
  end

  def domain_score_report
    return unless params['type'] == 'basic_info'
    @client_grid.column(:assessments, header: t('.assessments')) do |client|
      client.assessments.map(&:basic_info).join("\x0D\x0A")
    end
    @client_grid.column_names << :assessments if @client_grid.column_names.any?
  end

  def form_builder_report
    column_form_builder.each do |field|
      fields = field.split('_')
      @client_grid.column(:"#{fields.last.parameterize('_')}", header: fields.last) do |client|
        custom_field_properties = client.custom_field_properties.properties_by(fields.last)
        custom_field_properties.map{ |properties| format_properties_value(properties) }.join("\n")
      end
    end
  end

  def admin_client_grid
    if params[:client_grid] && params[:client_grid][:quantitative_types]
      quantitative_types = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(qType: quantitative_types))
    else
      # @client_grid = ClientGrid.new(params[:client_grid].merge!(dynamic_columns: form_builder_column))
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(dynamic_columns: column_form_builder))
    end
  end

  def non_admin_client_grid
    if params[:client_grid] && params[:client_grid][:quantitative_types]
      quantitative_types = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user, qType: quantitative_types))
    else
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user))
    end
  end

  def column_form_builder
    advanced_search_params = params[:client_advanced_search]
    if advanced_search_params.present? && advanced_search_params[:basic_rules].present?
      AdvancedSearches::ColumnGenerator.new(eval advanced_search_params[:basic_rules]).generate
    else
      []
    end
  end
end
