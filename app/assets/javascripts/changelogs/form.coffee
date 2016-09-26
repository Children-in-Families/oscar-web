# CIF.ChangelogsNew = CIF.ChangelogsCreate = CIF.ChangelogsEdit = CIF.ChangelogsUpdate = do ->
#   _init = ->
#     _triggerAfterAddingChange()

#   _triggerAfterAddingChange = ->
#     $('#changelog_type').on 'cocoon:after-insert', (e, insertedItem) ->
#       insertedItem.find('label').hide()

#   { init: _init }