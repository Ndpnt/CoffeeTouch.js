# if(myObject instanceof jQuery){
#   alert("myObject is a jQuery object");
# }

$ ->
  lastGesture = ""
  $('#gesture_name').keyup (event) ->
    $('#animation_box').unbindGesture lastGesture, callbackFunction
    lastGesture = $(event.srcElement).val().toLowerCase()
    $('#animation_box').onGesture(lastGesture, callbackFunction)
    
  callbackFunction = ->
    $('#animation_box').stop(true, false).animate({
      backgroundColor: '#ccc'
    }, 500 ).animate({
      backgroundColor: '#123'
    }, 500 )
    
