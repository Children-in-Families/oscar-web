CIF.ClientsVersion = CIF.FamiliesVersion = CIF.PartnersVersion = CIF.UsersVersion =
CIF.DomainsVersion = CIF.Domain_groupsVersion = CIF.AgenciesVersion = CIF.ProvnicesVersion =
CIF.Referal_sourcesVersion = CIF.Quantitative_typesVersion = CIF.InterventionsVersion = CIF.LocationsVersion =
CIF.MaterailsVersion = CIF.Progess_notesVersion = CIF.ChangelogsVersion = CIF.DepartmentsVersion =  do ->
  _init = ->
    _submitPerPageParams()

  _submitPerPageParams = ->
    $('#per_page_form form select').on 'change', ->
      $('#per_page_form form').submit();

  { init: _init }
