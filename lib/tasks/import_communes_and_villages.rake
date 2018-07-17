namespace :communes_and_villages do
  desc 'Import all communes and villages provided by NCDD'
  task import: :environment do
    Organization.where.not(short_name: Organization::BROAD_NGOS).each do |org|
      Organization.switch_to org.short_name

      files = [
        'Gazetteer_BAT_12_Jul_2018.xlsx', 'Gazetteer_BMC_12_Jul_2018.xlsx',
        'Gazetteer_KAM_12_Jul_2018.xlsx', 'Gazetteer_KCH_12_Jul_2018.xlsx',
        'Gazetteer_KDL_12_Jul_2018.xlsx', 'Gazetteer_KEP_12_Jul_2018.xlsx',
        'Gazetteer_KKG_12_Jul_2018.xlsx', 'Gazetteer_KPC_12_Jul_2018.xlsx',
        'Gazetteer_KPT_12_Jul_2018.xlsx', 'Gazetteer_KRT_12_Jul_2018.xlsx',
        'Gazetteer_KSP_12_Jul_2018.xlsx', 'Gazetteer_MKR_12_Jul_2018.xlsx',
        'Gazetteer_OMC_12_Jul_2018.xlsx', 'Gazetteer_PLN_12_Jul_2018.xlsx',
        'Gazetteer_PNP_12_Jul_2018.xlsx', 'Gazetteer_PUR_12_Jul_2018.xlsx',
        'Gazetteer_PVG_12_Jul_2018.xlsx', 'Gazetteer_PVR_12_Jul_2018.xlsx',
        'Gazetteer_RAT_12_Jul_2018.xlsx', 'Gazetteer_SHV_12_Jul_2018.xlsx',
        'Gazetteer_SRP_12_Jul_2018.xlsx', 'Gazetteer_STG_12_Jul_2018.xlsx',
        'Gazetteer_SVR_12_Jul_2018.xlsx', 'Gazetteer_TAK_12_Jul_2018.xlsx',
        'Gazetteer_TKM_12_Jul_2018.xlsx'
      ]
      files.each do |file_name|
        import = VillageImporter::Import.new(file_name)
        import.communes_and_villages
      end
    end
  end
end
