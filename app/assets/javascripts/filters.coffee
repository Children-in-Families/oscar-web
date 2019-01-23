$(document).on 'ready page:load', ->

  indexes = ['clients-index','families-index','partners-index','users-index', 'progress_notes-index'];
  body = $('body').attr('id')

  if indexes.indexOf(body) > -1
    $('.integer_filter').attr('type', 'number')
    $('.grid-form .datagrid-filter, .grid-form .domain-filter').each ->
      $(@).addClass 'form-group col-xs-12 col-sm-6 col-lg-4'
      $(@).children('input, select').addClass 'form-control'

    $('.date-filter-group').each (index, element) ->
      $(@).children('input, select').addClass 'form-control'

    $('.grid-form .datagrid-actions').addClass('col-xs-12')
    $('.grid-form .datagrid-actions input').addClass 'btn btn-primary'
    $('.grid-form .datagrid-actions a').addClass 'btn btn-default'

    tables = $('table#clients-list, table#csi-assessment-score, table#custom-assessment-score')
    for table in tables
      noResultClient = $(table).find('.dataTables_empty')
      if noResultClient.length == 1
        data = $(table).attr('id')
        $(".btn-export.#{data}").addClass('disabled')
