(function() {
  window.onload = function() {
    var $, Add, DragEnd, DragStart, Dragging, DrawCanvas, DrawValidatePoints, SelectPoint, Validate, allPoint, allValidatePoint, canvas, ctx, dPoint, drag, firsttime, init, j, point, style;
    $ = function(element) {
      return document.getElementById(element);
    };
    canvas = $('canvas');
    ctx = canvas.getContext("2d");
    ctx.lineCap = "round";
    ctx.lineJoin = "round";
    firsttime = true;
    $('canvas').bind("tap", function(params) {
      return SelectPoint(params.first.x, params.first.y);
    });
    $('canvas').bind("tap,tap", function(params) {
      var p1, p2;
      p1 = {
        x: params.first.x,
        y: params.first.y
      };
      p2 = {
        x: params.second.x,
        y: params.second.y
      };
      return init(p1, p2);
    });
    $('canvas').bind("drag", function(params) {
      if (firsttime) {
        DragStart(params);
        return firsttime = false;
      } else {
        return Dragging(params);
      }
    });
    $('canvas').bind("doubletap", function(params) {
      return Add(params.first.x, params.first.y);
    });
    $('canvas').bind("tap,tap,tap", function(params) {
      return Validate();
    });
    $('canvas').bind("dragend", function(params) {
      firsttime = true;
      return DragEnd(params);
    });
    $('canvas').bind("all", function(a, params) {
      return $('debug').innerHTML = a + "<br/>" + $('debug').innerHTML;
    });
    style = {};
    allPoint = [];
    point = {};
    allValidatePoint = [];
    dPoint = {};
    drag = null;
    style = {
      curve: {
        width: 4,
        color: "#333"
      },
      cpline: {
        width: 1,
        color: "#C00"
      },
      point: {
        radius: 15,
        width: 2,
        color: "#900",
        fill: "rgba(200,200,200,0.5)",
        arc1: 0,
        arc2: 2 * Math.PI
      }
    };
    init = function(a, b) {
      var point1, point2;
      point1 = {
        p: {
          x: a.x,
          y: a.y
        },
        cp: {
          x: a.x + 50,
          y: a.y + 50
        },
        validate: false,
        selected: false
      };
      point2 = {
        p: {
          x: b.x,
          y: b.y
        },
        cp: {
          x: b.x + 50,
          y: b.y + 50
        },
        validate: false,
        selected: false
      };
      allPoint.push(point1);
      allPoint.push(point2);
      return DrawCanvas();
    };
    DragEnd = function(e) {
      drag = null;
      return DrawCanvas();
    };
    Add = function(x, y) {
      point = {
        p: {
          x: x,
          y: y
        },
        cp: {
          x: x + 50,
          y: y + 50
        },
        validate: false,
        selected: false
      };
      allPoint.push(point);
      return DrawCanvas();
    };
    j = 0;
    Validate = function() {
      var i, _ref;
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      for (i = 0, _ref = allPoint.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        allPoint[i].validate = true;
        if (!(allPoint[i].group != null)) {
          allPoint[i].group = j;
        }
      }
      j++;
      return DrawValidatePoints();
    };
    DrawCanvas = function() {
      var i, radius, value, _ref;
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      for (value in allPoint) {
        if (allPoint[value].validate === false) {
          if (allPoint[value].p) {
            ctx.lineWidth = style.cpline.width;
            ctx.strokeStyle = style.cpline.color;
            ctx.beginPath();
            ctx.moveTo(allPoint[value].p.x, allPoint[value].p.y);
            ctx.lineTo(allPoint[value].cp.x, allPoint[value].cp.y);
            ctx.stroke();
            ctx.closePath();
          }
        }
      }
      for (i = 0, _ref = allPoint.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        if (allPoint[i].validate === false && allPoint[i + 1]) {
          ctx.lineWidth = style.curve.width;
          ctx.strokeStyle = style.curve.color;
          ctx.beginPath();
          ctx.moveTo(allPoint[i].p.x, allPoint[i].p.y);
          ctx.bezierCurveTo(allPoint[i].cp.x, allPoint[i].cp.y, allPoint[i + 1].cp.x, allPoint[i + 1].cp.y, allPoint[i + 1].p.x, allPoint[i + 1].p.y);
          ctx.stroke();
          ctx.closePath();
        }
      }
      for (value in allPoint) {
        if (allPoint[value].validate === false) {
          if (allPoint[value].p) {
            ctx.lineWidth = style.point.width;
            ctx.strokeStyle = style.point.color;
            ctx.fillStyle = style.point.fill;
            ctx.beginPath();
            radius = allPoint[value].selected === true ? 40 : style.point.radius;
            ctx.arc(allPoint[value].p.x, allPoint[value].p.y, radius, style.point.arc1, style.point.arc2, true);
            ctx.fill();
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(allPoint[value].cp.x, allPoint[value].cp.y, style.point.radius, style.point.arc1, style.point.arc2, true);
            ctx.fill();
            ctx.stroke();
            ctx.closePath();
          }
        }
      }
      return DrawValidatePoints();
    };
    DrawValidatePoints = function() {
      var i, _ref, _results;
      _results = [];
      for (i = 0, _ref = allPoint.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        _results.push(allPoint[i].validate === true && allPoint[i + 1] && allPoint[i].group === allPoint[i + 1].group ? (ctx.lineWidth = style.curve.width, ctx.strokeStyle = style.curve.color, ctx.beginPath(), ctx.moveTo(allPoint[i].p.x, allPoint[i].p.y), ctx.bezierCurveTo(allPoint[i].cp.x, allPoint[i].cp.y, allPoint[i + 1].cp.x, allPoint[i + 1].cp.y, allPoint[i + 1].p.x, allPoint[i + 1].p.y), ctx.stroke(), ctx.closePath()) : void 0);
      }
      return _results;
    };
    DragStart = function(event) {
      var dcx, dcy, dx, dy, e, value, _results;
      e = {
        x: event.first.x,
        y: event.first.y
      };
      dx = dy = 0;
      _results = [];
      for (value in allPoint) {
        if (allPoint[value].validate === false) {
          if (allPoint[value].p) {
            dx = allPoint[value].p.x - e.x;
            dy = allPoint[value].p.y - e.y;
            dcx = allPoint[value].cp.x - e.x;
            dcy = allPoint[value].cp.y - e.y;
            if ((dx * dx) + (dy * dy) < style.point.radius * style.point.radius && allPoint[value].selected === true) {
              drag = allPoint[value].p;
              dPoint = e;
              return;
            }
            if ((dcx * dcx) + (dcy * dcy) < style.point.radius * style.point.radius && allPoint[value].selected === true) {
              drag = allPoint[value].cp;
              dPoint = e;
              return;
            }
          }
        }
      }
      return _results;
    };
    Dragging = function(event) {
      var e;
      if (drag != null) {
        e = {
          x: event.first.x,
          y: event.first.y
        };
        drag.x += e.x - dPoint.x;
        drag.y += e.y - dPoint.y;
        dPoint = e;
        return DrawCanvas();
      }
    };
    return SelectPoint = function(x, y) {
      var dcx, dcy, dx, dy, e, value, _results;
      e = {
        x: x,
        y: y
      };
      dx = dy = 0;
      _results = [];
      for (value in allPoint) {
        allPoint[value].selected = false;
        if (allPoint[value].validate === false) {
          if (allPoint[value].p) {
            dx = allPoint[value].p.x - e.x;
            dy = allPoint[value].p.y - e.y;
            dcx = allPoint[value].cp.x - e.x;
            dcy = allPoint[value].cp.y - e.y;
            if ((dx * dx) + (dy * dy) < style.point.radius * style.point.radius) {
              allPoint[value].selected = true;
            } else if ((dcx * dcx) + (dcy * dcy) < style.point.radius * style.point.radius) {
              allPoint[value].selected = true;
            }
          }
        }
        _results.push(DrawCanvas());
      }
      return _results;
    };
  };
}).call(this);
