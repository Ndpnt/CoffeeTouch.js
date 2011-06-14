(function() {
  window.onload = function() {
    var $, xAngle, yAngle, zAngle;
    $ = function(element) {
      return document.getElementById(element);
    };
    xAngle = 0;
    yAngle = 0;
    zAngle = 0;
    $('body').onGesture("flick:up", function(params) {
      xAngle += 360;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
    });
    $('body').onGesture("flick:down", function(params) {
      xAngle -= 360;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
    });
    $('body').onGesture("flick:left", function(params) {
      yAngle -= 360;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
    });
    $('body').onGesture("flick:right", function(params) {
      yAngle += 360;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
    });
    return $('body').onGesture("rotation", function(params) {
      zAngle = params.global.rotation;
      return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
    });
  };
}).call(this);
