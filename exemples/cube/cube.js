(function() {
  window.onload = function() {
    var $, xAngle, yAngle, zAngle;
    $ = function(element) {
      return document.getElementById(element);
    };
    xAngle = 0;
    yAngle = 0;
    zAngle = 0;
    $('body').bind("flick:up", function(params) {
      if ((yAngle % 360) === 0) {
        xAngle += 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((yAngle % 360) === -90 || (yAngle % 360) === 90) {
        zAngle += 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((yAngle % 360) === -180 || (yAngle % 360) === 180) {
        xAngle -= 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((yAngle % 360) === -270 || (yAngle % 360) === 270) {
        zAngle -= 90;
        return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
    });
    $('body').bind("flick:down", function(params) {
      if ((yAngle % 360) === 0) {
        xAngle -= 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((yAngle % 360) === -90 || (yAngle % 360) === 90) {
        zAngle += 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((yAngle % 360) === -180 || (yAngle % 360) === 180) {
        xAngle += 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((yAngle % 360) === -270 || (yAngle % 360) === 270) {
        zAngle += 90;
        return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
    });
    $('body').bind("flick:left", function(params) {
      if ((xAngle % 360) === 0) {
        yAngle -= 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((xAngle % 360) === -90 || (xAngle % 360) === 90) {
        zAngle -= 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((xAngle % 360) === -180 || (xAngle % 360) === 180) {
        yAngle += 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((xAngle % 360) === -270 || (xAngle % 360) === 270) {
        zAngle += 90;
        return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
    });
    $('body').bind("flick:right", function(params) {
      if ((xAngle % 360) === 0) {
        yAngle += 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((xAngle % 360) === -90 || (xAngle % 360) === 90) {
        zAngle += 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((xAngle % 360) === -180 || (xAngle % 360) === 180) {
        yAngle -= 90;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((xAngle % 360) === -270 || (xAngle % 360) === 270) {
        zAngle -= 90;
        return $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
    });
    return $('body').bind("right", function(params) {
      if ((xAngle % 360) === 0) {
        yAngle += params.first.panX * 90 / window.innerWidth;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((xAngle % 360) === -90 || (xAngle % 360) === 90) {
        zAngle += params.first.panX * 90 / window.innerWidth;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((xAngle % 360) === -180 || (xAngle % 360) === 180) {
        yAngle -= params.first.panX * 90 / window.innerWidth;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      if ((xAngle % 360) === -270 || (xAngle % 360) === 270) {
        zAngle -= params.first.panX * 90 / window.innerWidth;
        $('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateZ(" + zAngle + "deg)";
      }
      return $('debug').innerHTML += params.first.x * 90 / window.innerWidth + " inner : " + window.innerWidth;
    });
    /*
    $('body').bind "all", (a, params) ->
    		$('debug').innerHTML = params.global.type
    */
  };
}).call(this);
