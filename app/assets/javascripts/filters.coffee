$(document).on 'ready page:load', ->

  indexes = ['clients-index','families-index','partners-index','users-index', 'progress_notes-index'];
  body = $('body').attr('id')

  if indexes.indexOf(body) > -1
    $('.integer_filter').attr('type': 'number')
    $('.grid-form .datagrid-filter').each ->
      $(@).addClass 'form-group col-xs-12 col-sm-4 col-md-3'
      $(@).children('input, select').addClass 'form-control'

    $('.date-filter-group').each (index, element) ->
      $(@).children('input, select').addClass 'form-control'

    $('.grid-form .datagrid-actions').addClass('col-xs-12')
    $('.grid-form .datagrid-actions input').addClass 'btn btn-primary'
    $('.grid-form .datagrid-actions a').addClass 'btn btn-default'

    noResults = $('table').find('.noresults')
    if noResults.length == 1
      $('.btn-export').addClass('disabled')
