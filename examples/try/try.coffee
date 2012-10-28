$ ->
  lastGesture = ""

  $('#gesture_name').keyup (event) ->
    $('#animation_box').unbindGesture lastGesture, callbackFunction
    lastGesture = $(event.srcElement).val().toLowerCase()
    $('#animation_box').onGesture(lastGesture, callbackFunction)

  callbackFunction = ->
    $(this).addClass('shake')
    setTimeout =>
      $(this).removeClass('shake')
    , 500
