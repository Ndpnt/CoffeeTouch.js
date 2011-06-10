(function() {
  window.onload = function() {
    var $, xAngle, yAngle;
    $ = function(element) {
      return document.getElementById(element);
    };
    xAngle = 0;
    yAngle = 0;
    $('cube').bind("left", function(params) {
      yAngle -= 90;
      return $('cube').style.webkitTransform = "rotateY(-" + params.first.y + "deg)";
    });
    $('cube').bind("right", function(params) {
      yAngle += 90;
      return $('cube').style.webkitTransform = "rotateY(" + params.first.y + "deg)";
    });
    $('cube').bind("up", function(params) {
      xAngle += 90;
      return $('cube').style.webkitTransform = "rotateX(" + params.first.x + "deg)";
    });
    $('cube').bind("down", function(params) {
      xAngle -= 90;
      return $('cube').style.webkitTransform = "rotateX(-" + params.first.x + "deg)";
    });
    return $('cube').bind("all", function(a, params) {
      return $('debug').innerHTML = params.global.type;
    });
  };
}).call(this);
