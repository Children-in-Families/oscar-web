CIF.ClientsVersion = CIF.FamiliesVersion = CIF.PartnersVersion = CIF.UsersVersion =
CIF.DomainsVersion = CIF.Domain_groupsVersion = CIF.AgenciesVersion = CIF.ProvincesVersion =
CIF.Referral_sourcesVersion = CIF.Quantitative_typesVersion = CIF.InterventionsVersion = CIF.LocationsVersion =
CIF.MaterialsVersion = CIF.Progess_notesVersion = CIF.ChangelogsVersion =
CIF.DepartmentsVersion = CIF.Quantitative_casesVersion = do ->

  _init = ->
    _submitPerPageParams()

  _submitPerPageParams = ->
    $('#per_page_form form select').on 'change', ->
      $('#per_page_form form').submit();

  { init: _init }
