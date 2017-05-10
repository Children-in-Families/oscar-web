module ClientGridOptions
  def choose_grid
    if current_user.admin? || current_user.strategic_overviewer?
      admin_client_grid
    elsif current_user.case_worker? || current_user.any_manager?
      non_admin_client_grid
    end
  end

  def columns_visibility
    @client_columns ||= ClientColumnsVisibility.new(@client_grid, params)
    @client_columns.visible_columns
  end

  def domain_score_report
    return unless params['type'] == 'basic_info'
    @client_grid.column(:assessments, header: t('.assessments')) do |client|
      client.assessments.map(&:basic_info).join("\x0D\x0A")
    end
    @client_grid.column_names << :assessments if @client_grid.column_names.any?
  end

  def admin_client_grid
    if params[:client_grid] && params[:client_grid][:quantitative_types]
      quantitative_types = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(qType: quantitative_types))
    else
      @client_grid = ClientGrid.new(params[:client_grid])
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
  
end