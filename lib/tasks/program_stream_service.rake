namespace :program_stream_service do
  desc "Create Program Stream Services"
  task create: :environment do
    sheet_name = 'Sheet1'
    data       = ImportStaticService::DateService.new(sheet_name, 'brc')
    data.import
  end
end
