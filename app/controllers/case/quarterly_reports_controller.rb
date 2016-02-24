class Case::QuarterlyReportsController < ApplicationController
  load_and_authorize_resource

  before_action :find_case
  before_action :set_quarterly_report, only: [:show]

  def index
    @quarterly_reports_grid = QuarterlyReportsGrid.new(params[:quarterly_reports_grid])
    @quarterly_reports_grid.scope {|scope| scope.where(case_id: @case.id).paginate(page: params[:page], per_page: 20)}
  end

  def show
  end

  private

  def set_quarterly_report
    @quarterly_report = @case.quarterly_reports.find(params[:id])
  end

  def find_case
    @case = Case.find(params[:case_id])
  end
end
