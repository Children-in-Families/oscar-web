namespace :ec do
  desc 'Import all CIF task'
  task modify: :environment do
    sheet_name = 'EC Child Referral List'
    import     = Importer::Import.new(sheet_name)

    import.modify_ec
  end
end


