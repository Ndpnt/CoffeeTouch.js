(function() {
  window.onload = function() {
    var $, X, Y, canvas, draw, first;
    $ = function(element) {
      return document.getElementById(element);
    };
    canvas = new window.Viewer($('canvas'));
    $('canvas').bind("tap", function(params) {
      return canvas.displayPoint(params.first.x, params.first.y, "FF0000");
    });
    $('canvas').bind("tap,tap", function(params) {
      canvas.displayPoint(params.first.x, params.first.y, "#FF0000");
      canvas.displayPoint(params.second.x, params.second.y, "#FF0000");
      return canvas.displayLine(params.first.x, params.first.y, params.second.x, params.second.y, "#0000AA");
    });
    $('canvas').bind("tap,tap,tap", function(params) {
      canvas.displayPoint(params.first.x, params.first.y, "#FF0000");
      canvas.displayPoint(params.second.x, params.second.y, "#FF0000");
      canvas.displayPoint(params.third.x, params.third.y, "#FF0000");
      canvas.displayLine(params.first.x, params.first.y, params.second.x, params.second.y, "#0000AA");
      canvas.displayLine(params.second.x, params.second.y, params.third.x, params.third.y, "#0000AA");
      return canvas.displayLine(params.first.x, params.first.y, params.third.x, params.third.y, "#0000AA");
    });
    X = 0;
    Y = 0;
    first = true;
    $('canvas').bind("right", function(params) {
      return draw(params);
    });
    $('canvas').bind("left", function(params) {
      return draw(params);
    });
    $('canvas').bind("up", function(params) {
      return draw(params);
    });
    $('canvas').bind("down", function(params) {
      return draw(params);
    });
    return draw = function(params) {
      var color, t;
      if (first) {
        first = false;
        X = params.first.x;
        Y = params.first.y;
      }
      if (params.global.type = "right" || (params.global.type = "left")) {
        t = params.first.panX * 300 / (window.screen.width * 3);
        $('debug').innerHTML += params.first.panX + "<br />";
      }
      if (params.global.type = "up") {
        color = params.first.panX * 255 / window.screen.height;
      }
      canvas.clear;
      canvas.displayPoint(X, Y, "rgb(" + color + "," + color + "," + color + ")", t);
      return $('canvas').bind("dragend", function(params) {
        canvas.displayPoint(X, Y, "rgb(" + color + "," + color + "," + color + ")", t);
        return first = true;
      });
    };
  };
}).call(this);
