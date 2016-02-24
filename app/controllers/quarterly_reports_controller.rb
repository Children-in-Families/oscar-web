class QuarterlyReportsController < ApplicationController
  load_and_authorize_resource

  def index
    @quarterly_reports_grid = QuarterlyReportsGrid.new(params[:quarterly_reports_grid]) do |scope|
      scope.page(params[:page])
    end
  end

  def show
  end

  private

  def set_quarterly_report
    @quarterly_report = QuarterlyReport.find(params[:id])
  end
end
