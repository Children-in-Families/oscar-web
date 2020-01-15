$(document).on 'ready page:load', ->

  indexes = ['clients-index','families-index','partners-index','users-index', 'progress_notes-index', 'calls-index'];
  body = $('body').attr('id')

  if indexes.indexOf(body) > -1
    tables = $('table#clients-list, table#csi-assessment-score, table#custom-assessment-score, table.call')
    for table in tables
      noResultClient = $(table).find('.dataTables_empty')
      if noResultClient.length == 1
        data = $(table).attr('id')
        $(".btn-export.#{data}").addClass('disabled')
