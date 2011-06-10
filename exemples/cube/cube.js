(function() {
  window.onload = function() {
    var $, xAngle, yAngle;
    $ = function(element) {
      return document.getElementById(element);
    };
    xAngle = 0;
    yAngle = 0;
    $('body').bind("left", function(params) {
      yAngle -= 90;
      return $('cube').style.webkitTransform = "rotateY(-" + params.first.y + "deg)";
    });
    $('body').bind("right", function(params) {
      yAngle += 90;
      return $('cube').style.webkitTransform = "rotateY(" + params.first.y + "deg)";
    });
    $('body').bind("up", function(params) {
      xAngle += 90;
      return $('cube').style.webkitTransform = "rotateX(" + params.first.x + "deg)";
    });
    $('body').bind("down", function(params) {
      xAngle -= 90;
      return $('cube').style.webkitTransform = "rotateX(-" + params.first.x + "deg)";
    });
    return $('body').bind("all", function(a, params) {
      return $('debug').innerHTML = params.global.type;
    });
  };
}).call(this);
