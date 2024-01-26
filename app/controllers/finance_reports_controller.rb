class FinanceReportsController < AdminController
  def index
    @reports = BillableReport.recent.by_current_instance.page(params[:page]).per(12)
  end

  def show
    respond_to do |format|
      report = BillableReport.find(params[:id])

      format.xls do
        filename = "tmp/billable-report-#{report.organization_short_name}-#{Date.today.strftime("%Y-%m-%d")}.xls"
        BillableReportExportHandler.call(report, filename)
        send_file filename, disposition: :attachment
      end
    end
  end
end
