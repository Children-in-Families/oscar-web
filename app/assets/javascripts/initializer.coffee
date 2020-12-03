CIF.Initializer =
  exec: (pageName) ->
    if pageName && CIF[pageName]
      CIF[pageName]['init']()

  currentPage: ->
    return '' unless $('body').attr('id')

    bodyId      = $('body').attr('id').split('-')
    action      = CIF.Util.capitalize(bodyId[1])
    controller  = CIF.Util.capitalize(bodyId[0])
    controller + action

  init: ->
    CIF.Initializer.exec('Common')
    if @currentPage()
      CIF.Initializer.exec(@currentPage())


$(document).on 'ready page:load', ->
  CIF.Initializer.init()
