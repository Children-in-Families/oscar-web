class CsiStatisticsController < AdminController
  before_action :set_statistic_score

  def index
    @csi_statistics = @statistic_score.assessment_domain_score
  end

  private
  def set_statistic_score
    @statistic_score = CsiStatistic.new(params[:start_date], params[:end_date])
  end
end