class ReportsController < AdminController
  before_action :set_csi_domain, :set_case_statistic, only: [:index]
  
  def index
    @csi_statistics = @statistic_score.assessment_domain_score
    @cases_statistics = @cases_statistic.statistic_data
  end

  private
  def set_csi_domain
    @statistic_score = CsiStatistic.new(params[:csi_start_date], params[:csi_end_date])
  end

  def set_case_statistic
    @cases_statistic = CaseStatistic.new(params[:case_start_date], params[:case_end_date])
  end
end