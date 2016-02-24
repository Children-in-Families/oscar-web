$(document).on 'ready page:load', ->

  indexes = ['clients-index','families-index','partners-index','users-index'];
  body = $('body').attr('id')

  if indexes.indexOf(body) > -1
    $('.grid-form .datagrid-filter').each ->
      $(this).addClass 'form-group col-sm-6'
        .css 'padding', '5px'
        .children('label').css 'min-width', '215px'
      $(this).children('input, select').addClass 'form-control'

    $('.grid-form .datagrid-actions').addClass 'col-sm-12'
    $('.grid-form .datagrid-actions input').addClass 'btn btn-primary'
    $('.grid-form .datagrid-actions a').addClass 'btn btn-default'
      .css 'padding', '7px 20px'

    noResults = $('table').find('.noresults')
    if noResults.length == 1
      noResults.html('No results found')
      $('.btn-export').addClass('disabled')
