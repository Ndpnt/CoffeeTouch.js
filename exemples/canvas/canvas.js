(function() {
  window.onload = function() {
    var $, canvas;
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
      return canvas.displayLine(params.first.x, params.first.y, params.second.x, params.second.y, "#0000FF");
    });
    $('canvas').bind("tap,tap,tap", function(params) {
      canvas.displayPoint(params.first.x, params.first.y, "#FF0000");
      canvas.displayPoint(params.second.x, params.second.y, "#FF0000");
      canvas.displayPoint(params.third.x, params.third.y, "#FF0000");
      canvas.displayLine(params.first.x, params.first.y, params.second.x, params.second.y, "#0000AA");
      canvas.displayLine(params.second.x, params.second.y, params.third.x, params.third.y, "#0000AA");
      return canvas.displayLine(params.first.x, params.first.y, params.third.x, params.third.y, "#0000AA");
    });
    return $('canvas').bind("all", function(a, params) {
      return $('debug').innerHTML = params.global.type;
    });
  };
}).call(this);
