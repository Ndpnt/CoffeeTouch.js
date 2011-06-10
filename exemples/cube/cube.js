(function() {
  window.onload = function() {
    var $, xAngle, yAngle;
    $ = function(element) {
      return document.getElementById(element);
    };
    xAngle = 0;
    yAngle = 0;
    $('body').bind("left", function(params) {
      yAngle -= params.first.y * 90 / window.screen.height;
      return $('cube').style.webkitTransform = "rotateY(-" + yAngle + "deg)";
    });
    $('body').bind("right", function(params) {
      yAngle += params.first.y * 90 / window.screen.height;
      return $('cube').style.webkitTransform = "rotateY(" + yAngle + "deg)";
    });
    $('body').bind("up", function(params) {
      xAngle += params.first.x * 90 / window.screen.width;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg)";
    });
    $('body').bind("down", function(params) {
      xAngle -= params.first.x * 90 / window.screen.width;
      return $('cube').style.webkitTransform = "rotateX(-" + xAngle + "deg)";
    });
    return $('body').bind("all", function(a, params) {
      return $('debug').innerHTML = params.global.type;
    });
  };
}).call(this);
