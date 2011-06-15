(function() {
  window.onload = function() {
    var $, c, canvas, context, draw, previousX, previousY, started;
    $ = function(element) {
      return document.getElementById(element);
    };
    canvas = new window.Viewer($('canvas'));
    $('canvas').onGesture("tap", function(params) {
      return canvas.displayPoint(params.first.x, params.first.y, "FF0000");
    });
    $('canvas').onGesture("tap,tap", function(params) {
      return canvas.displayLine(params.first.x, params.first.y, params.second.x, params.second.y, "#0000AA");
    });
    $('canvas').onGesture("tap,tap,tap", function(params) {
      canvas.displayPoint(params.first.x, params.first.y, "#FF0000");
      canvas.displayPoint(params.second.x, params.second.y, "#FF0000");
      canvas.displayPoint(params.third.x, params.third.y, "#FF0000");
      canvas.displayLine(params.first.x, params.first.y, params.second.x, params.second.y, "#0000AA");
      canvas.displayLine(params.second.x, params.second.y, params.third.x, params.third.y, "#0000AA");
      return canvas.displayLine(params.first.x, params.first.y, params.third.x, params.third.y, "#0000AA");
    });
    $('canvas').onGesture("right", function(params) {
      return draw(params);
    });
    $('canvas').onGesture("left", function(params) {
      return draw(params);
    });
    $('canvas').onGesture("up", function(params) {
      return draw(params);
    });
    $('canvas').onGesture("down", function(params) {
      return draw(params);
    });
    started = false;
    c = $("canvas");
    context = c.getContext('2d');
    context.lineWidth = 2;
    context.strokeStyle = "rgba(0,0,0,1)";
    previousX = 0;
    previousY = 0;
    draw = function(params) {
      if (!started) {
        previousX = params.first.x;
        previousY = params.first.y;
        context.beginPath();
        context.moveTo(params.first.x, params.first.y);
        return started = true;
      } else {
        context.quadraticCurveTo(params.first.startX, params.first.startY, params.first.x, params.first.y);
        context.stroke();
        previousX = params.first.x;
        return previousY = params.first.y;
      }
    };
    $('canvas').onGesture("dragend", function(params) {
      started = false;
      return context.closePath();
    });
    return $('canvas').onGesture("all", function(a, params) {
      return $('debug').innerHTML += a + "<br>";
    });
  };
}).call(this);
