class CIF.ShowMore
  constructor: (elements, height, showText, hideText) ->
    @showMore(elements, height, showText, hideText)

  showMore: (elements, height, showText, hideText) ->
    setTimeout (->
      $.each $(elements), (index, element) ->
        elementHeight = $(element).height()
        if elementHeight > height
          if $(element).children().length > 0
            childElement = $(element).children()
            $(childElement).wrap("<div class='showmore_content' style='height: #{height}px;'></div>")
            $(element).append("<div class='showmore_trigger'><span class='more'><a>#{showText}</a></span><span class='less'><a>#{hideText}</a></span></div>")

          else
            $(element).wrapInner("<div class='showmore_content' style='height: #{height}px;'></div>")
            $(element).append("<div class='showmore_trigger'><span class='more'><a>#{showText}</a></span><span class='less'><a>#{hideText}</a></span></div>")

      $('.showmore_trigger span.less').css('display', 'none')

      $('.showmore_trigger span.more a').click ->
        parentElement = $(@).parents('.td-content')
        triggerElement = parentElement.find('.showmore_trigger')
        triggerElement.children(':first').hide()
        triggerElement.children(':last').show()
        childHeight = parentElement.find('.showmore_content').children(':first').height()
        parentElement.find('.showmore_content').css({'height': 'auto'})

      $('.showmore_trigger span.less a').click ->
        parentElement = $(@).parents('.td-content')
        parentElement.find('.showmore_content').css({'height': "#{height}px"})
        triggerElement = parentElement.find('.showmore_trigger')
        triggerElement.children(':first').show()
        triggerElement.children(':last').hide()
      ), 500
