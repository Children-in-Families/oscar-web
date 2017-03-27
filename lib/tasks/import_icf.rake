namespace :icf do
  desc 'Import all ICF clients and related data'
  task import: :environment do
    icf_org = Organization.find_by(short_name: 'icf')
    Organization.switch_to icf_org.short_name

    # import     = import_sheet('users')
    # import.users

    import     = import_sheet('donors')
    import.donors

    import     = import_sheet('families')
    import.families

    import     = import_sheet('clients')
    import.clients

  end

  private

  def import_sheet(sheet_name)
    IcfImporter::Import.new(sheet_name)
  end
end
