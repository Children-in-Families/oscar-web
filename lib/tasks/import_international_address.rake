namespace :international_address do
  desc 'Import international Address'
  task import: :environment do
    Organization.switch_to 'cps'
    import = ImportInternationalAddress::Import.new('Provinces', 'vendor/data/Thai.xlsx')
    import.province_for_thai

    import = ImportInternationalAddress::Import.new('Districts', 'vendor/data/Thai.xlsx')
    import.district_for_thai

    import = ImportInternationalAddress::Import.new('Sub Districts', 'vendor/data/Thai.xlsx')
    import.subdistrict_for_thai

    Organization.switch_to 'kmo'

    import = ImportInternationalAddress::Import.new('States', 'vendor/data/Myanmar.xlsx')
    import.state_for_myanmar

    import = ImportInternationalAddress::Import.new('Townships', 'vendor/data/Myanmar.xlsx')
    import.township_for_myanmar
  end
end
