namespace :ngo_usage_report do
  desc "Remind Case Worker incomplete overdue tasks weekly"
  task generate: :environment do
    NgoUsageReport.new
  end
end