class StatisticsController < AdminController
  before_action :set_csi_domain, only: [:csi_domain]
  def index
  end

  def csi_domain
    @csi_statistics = @statistic_score.assessment_domain_score
  end

  def case_type
    @cases_statistics = CaseStatistic::statistic_data
  end

  private
  def set_csi_domain
    @statistic_score = CsiStatistic.new(params[:start_date], params[:end_date])
  end
end