(function() {
  window.onload = function() {
    var $, add, allPoint, allvalidatePoint, canvas, changeRadius, changeRadiusSelection, clear, ctx, dPoint, drag, dragEnd, dragStart, dragging, drawCanvas, drawvalidatePoints, firsttime, init, j, point, selectPoint, style, validate;
    $ = function(element) {
      return document.getElementById(element);
    };
    canvas = $('canvas');
    ctx = canvas.getContext("2d");
    ctx.lineCap = "round";
    ctx.lineJoin = "round";
    firsttime = true;
    $('canvas').onGesture("tap", function(params) {
      selectPoint(params.fingers[0].x, params.fingers[0].y);
      ctx.fillStyle = "rgba(0,0,0,1)";
      ctx.beginPath();
      ctx.arc(params.fingers[0].x, params.fingers[0].y, 3, 0, Math.PI * 2, true);
      ctx.closePath();
      return ctx.fill();
    });
    $('canvas').onGesture("tap,tap", function(params) {
      var p1, p2;
      p1 = {
        x: params.fingers[0].x,
        y: params.fingers[0].y
      };
      p2 = {
        x: params.fingers[1].x,
        y: params.fingers[1].y
      };
      return init(p1, p2);
    });
    $('canvas').onGesture("drag", function(params) {
      if (firsttime) {
        dragStart(params);
        return firsttime = false;
      } else {
        return dragging(params);
      }
    });
    $('canvas').onGesture("doubletap", function(params) {
      return add(params.fingers[0].x, params.fingers[0].y);
    });
    $('canvas').onGesture("tap,tap,tap", function(params) {
      return validate();
    });
    $('canvas').onGesture("tap", function(params) {
      return dragEnd(params);
    });
    $('canvas').onGesture("three:flick:down", function(params) {
      return clear();
    });
    $('canvas').onGesture("two:spread", function(params) {
      return changeRadiusSelection(params.scale);
    });
    $('canvas').onGesture("two:pinch", function(params) {
      return changeRadiusSelection(params.scale);
    });
    $('canvas').onGesture("three:spread", function(params) {
      return changeRadius(params.scale);
    });
    $('canvas').onGesture("three:pinch", function(params) {
      return changeRadius(params.scale);
    });
    style = {};
    allPoint = [];
    point = {};
    allvalidatePoint = [];
    dPoint = {};
    drag = null;
    ({
      red: 33,
      green: 33,
      blue: 33
    });
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
        radiusSelected: 35,
        width: 2,
        color: "#900",
        colorSelected: "#AAA",
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
          y: a.y + 50,
          selected: false
        },
        validate: false
      };
      point2 = {
        p: {
          x: b.x,
          y: b.y
        },
        cp: {
          x: b.x + 50,
          y: b.y + 50,
          selected: false
        },
        validate: false
      };
      allPoint.push(point1);
      allPoint.push(point2);
      return drawCanvas();
    };
    dragEnd = function(e) {
      drag = null;
      return drawCanvas();
    };
    add = function(x, y) {
      point = {
        p: {
          x: x,
          y: y,
          selected: false
        },
        cp: {
          x: x + 50,
          y: y + 50,
          selected: false
        },
        validate: false
      };
      allPoint.push(point);
      return drawCanvas();
    };
    changeRadiusSelection = function(scale) {
      var bool, i, _ref;
      bool = false;
      for (i = 0, _ref = allPoint.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        if (allPoint[i] && allPoint[i].selected === true) {
          this.bool = true;
          break;
        }
      }
      style.point.radiusSelected *= scale > 1 ? 1.1 : this.bool ? 0.9 : void 0;
      return drawCanvas();
    };
    changeRadius = function(scale) {
      style.point.radiusSelected *= scale > 1 ? 1.1 : 0.9;
      return drawCanvas();
    };
    j = 0;
    validate = function() {
      var i, _ref;
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      for (i = 0, _ref = allPoint.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        if (allPoint[i]) {
          allPoint[i].validate = true;
        }
        if (!allPoint[i].group) {
          allPoint[i].group = j;
        }
      }
      j++;
      return drawvalidatePoints();
    };
    drawCanvas = function() {
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
        if (allPoint[i] && allPoint[i].validate === false && allPoint[i + 1]) {
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
            radius = allPoint[value].p.selected === true ? style.point.radiusSelected : style.point.radius;
            ctx.arc(allPoint[value].p.x, allPoint[value].p.y, radius, style.point.arc1, style.point.arc2, true);
            ctx.fill();
            ctx.stroke();
            ctx.beginPath();
            radius = allPoint[value].cp.selected === true ? style.point.radiusSelected : style.point.radius;
            ctx.arc(allPoint[value].cp.x, allPoint[value].cp.y, radius, style.point.arc1, style.point.arc2, true);
            ctx.fill();
            ctx.stroke();
            ctx.closePath();
          }
        }
      }
      return drawvalidatePoints();
    };
    drawvalidatePoints = function() {
      var i, _ref, _results;
      _results = [];
      for (i = 0, _ref = allPoint.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        _results.push(allPoint[i] && allPoint[i].validate === true && allPoint[i + 1] && allPoint[i].group === allPoint[i + 1].group ? (ctx.lineWidth = style.curve.width, ctx.strokeStyle = style.curve.color, ctx.beginPath(), ctx.moveTo(allPoint[i].p.x, allPoint[i].p.y), ctx.bezierCurveTo(allPoint[i].cp.x, allPoint[i].cp.y, allPoint[i + 1].cp.x, allPoint[i + 1].cp.y, allPoint[i + 1].p.x, allPoint[i + 1].p.y), ctx.stroke(), ctx.closePath()) : void 0);
      }
      return _results;
    };
    dragStart = function(event) {
      var dcx, dcy, dx, dy, e, value, _results;
      e = {
        x: event.fingers[0].x,
        y: event.fingers[0].y
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
            if ((dx * dx) + (dy * dy) < style.point.radiusSelected * style.point.radiusSelected && allPoint[value].p.selected === true) {
              drag = allPoint[value].p;
              dPoint = e;
              return;
            }
            if ((dcx * dcx) + (dcy * dcy) < style.point.radiusSelected * style.point.radiusSelected && allPoint[value].cp.selected === true) {
              drag = allPoint[value].cp;
              dPoint = e;
              return;
            }
          }
        }
      }
      return _results;
    };
    dragging = function(event) {
      var e;
      if (drag != null) {
        e = {
          x: event.fingers[0].x,
          y: event.fingers[0].y
        };
        drag.x += e.x - dPoint.x;
        drag.y += e.y - dPoint.y;
        dPoint = e;
        return drawCanvas();
      }
    };
    selectPoint = function(x, y) {
      var dcx, dcy, dx, dy, e, value, _results;
      e = {
        x: x,
        y: y
      };
      dx = dy = 0;
      _results = [];
      for (value in allPoint) {
        if (allPoint[value].p) {
          allPoint[value].p.selected = false;
          allPoint[value].cp.selected = false;
        }
        if (allPoint[value].validate === false) {
          if (allPoint[value].p) {
            dx = allPoint[value].p.x - e.x;
            dy = allPoint[value].p.y - e.y;
            dcx = allPoint[value].cp.x - e.x;
            dcy = allPoint[value].cp.y - e.y;
            if ((dx * dx) + (dy * dy) < style.point.radius * style.point.radius) {
              allPoint[value].p.selected = true;
              drag = allPoint[value].p;
              dPoint = e;
              drawCanvas();
              return;
            }
            if ((dcx * dcx) + (dcy * dcy) < style.point.radius * style.point.radius) {
              allPoint[value].cp.selected = true;
              drag = allPoint[value].cp;
              dPoint = e;
              drawCanvas();
              return;
            }
          }
        }
      }
      return _results;
    };
    return clear = function() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      return allPoint = [];
    };
  };
}).call(this);
