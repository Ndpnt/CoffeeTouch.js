$(function() {
  var callback = function(el) {
    var $el = $(el);
    var animation = $el.data('animation');
    $el.addClass(animation);
    setTimeout(function(){
      $el.removeClass(animation);
    }, 500);
  };

  $("#tap")         .onGesture("tap"        , function() { callback(this); });
  $("#left")        .onGesture("left"       , function() { callback(this); });
  $("#flick_left")  .onGesture("flick:left" , function() { callback(this); });
  $("#left_left")   .onGesture("left,left"  , function() { callback(this); });
  $("#doubletap")   .onGesture("doubletap"  , function() { callback(this); });
  $("#pinch")       .onGesture("pinch"      , function() { callback(this); });
  $("#three_pinch") .onGesture("three:pinch", function() { callback(this); });
  $("#spread")      .onGesture("spread"     , function() { callback(this); });
  $("#rotate")      .onGesture("rotate"     , function() { callback(this); });
  $("#fixed")       .onGesture("fixed"      , function() { callback(this); });
  $("#fixedend")    .onGesture("fixedend"   , function() { callback(this); });

});
