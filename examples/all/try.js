$(function() {
  var basic = function(el) {
    $(el).find('.inner_box').stop(true,false).animate({opacity: 0}, 300).animate({opacity: 1}, 20);
  };
  var doubleTap = function(el) {
    $(el).find('.inner_box').stop(true,false).animate({opacity: 0}, 70).animate({opacity: 1}, 70).animate({opacity: 0}, 70).animate({opacity: 1}, 70);
  };
  var openLeft = function(el) {
    $(el).find('.inner_box').stop(true,false).animate({width: 0}, 500).animate({width: "100%"}, 500);
  };
  var flickLeft = function(el) {
    $(el).find('.inner_box').stop(true,false).animate({width: 0}, 300).animate({width: "100%"}, 200);
  };
  
  $("#tap")         .onGesture("tap"        , function() {basic(this);});
  $("#left")        .onGesture("left"       , function() {openLeft(this);});
  $("#flick_left")  .onGesture("flick:left" , function() {flickLeft(this);});
  $("#left_left")   .onGesture("left,left"  , function() {openLeft(this);});
  $("#doubletap")   .onGesture("doubletap"  , function() {doubleTap(this);});
  $("#pinch")       .onGesture("pinch"      , function() {basic(this);});
  $("#three_pinch") .onGesture("three:pinch", function() {basic(this);});
  $("#spread")      .onGesture("spread"     , function() {basic(this);});
  $("#rotate")      .onGesture("rotate"     , function() {basic(this);});
  $("#fixed")       .onGesture("fixed"      , function() {basic(this);});
  $("#fixedend")    .onGesture("fixedend"   , function() {basic(this);});

});