class NgoUsageReport
  def initialize
    generate
  end

  def generate
    NgoUsageReportWorker.perform_async
  end
end
