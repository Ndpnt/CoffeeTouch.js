// Generated by CoffeeScript 1.4.0
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
      var _this = this;
      $(this).addClass('shake');
      return setTimeout(function() {
        return $(_this).removeClass('shake');
      }, 500);
    };
  });

}).call(this);
