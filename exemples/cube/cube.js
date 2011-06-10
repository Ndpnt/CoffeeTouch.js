(function() {
  window.onload = function() {
    var $, xAngle, yAngle;
    $ = function(element) {
      return document.getElementById(element);
    };
    xAngle = 0;
    yAngle = 0;
    $('body').bind("flick:down", function(params) {
      xAngle -= 90;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg)";
    });
    $('body').bind("flick:up", function(params) {
      xAngle += 90;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg)";
    });
    $('body').bind("flick:left", function(params) {
      yAngle -= 90;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg)";
    });
    return $('body').bind("flick:right", function(params) {
      yAngle += 90;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg)";
    });
    /*
    $('body').bind "all", (a, params) ->
    		$('debug').innerHTML = params.global.type
    */
  };
}).call(this);
