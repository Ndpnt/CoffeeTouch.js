(function() {
  $(function() {
    var callbackFunction, lastGesture;
    lastGesture = "";
    $('#gesture_name').keyup(function(event) {
      $('#animation_box').unbindGesture(lastGesture, callbackFunction);
      lastGesture = $(event.srcElement).val().toLowerCase();
      return $('#animation_box').onGesture(lastGesture, callbackFunction);
    });
    return callbackFunction = function() {
      return $('#animation_box').stop(true, false).animate({
        backgroundColor: '#ccc'
      }, 500).animate({
        backgroundColor: '#123'
      }, 500);
    };
  });
}).call(this);
