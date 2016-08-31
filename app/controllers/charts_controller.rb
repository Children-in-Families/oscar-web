class ChartsController < AdminController

  def index
    chart_score = ChartScore.new
    @chart = chart_score.assessment_domain_score
  end
end