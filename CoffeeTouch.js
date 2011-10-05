(function() {
  var Analyser, Drag, EventGrouper, EventRouter, FingerGesture, FirstTouch, Fixed, GenericState, NoTouch, StateMachine, digit_name, distanceBetweenTwoPoints, getDirection, getDragDirection;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Element.prototype.onGesture = function(eventName, callback) {
    var calls, list;
    if (!(this.router != null)) {
      this.router = new EventRouter(this);
    }
    calls = this._callbacks || (this._callbacks = {});
    list = this._callbacks[eventName] || (this._callbacks[eventName] = []);
    list.push(callback);
    return this;
  };
  Element.prototype.unbindGesture = function(ev, callback) {
    var callbackfunction, calls, i, list, _len;
    if (!ev) {
      this._callbacks = {};
    } else if (calls = this._callbacks) {
      if (!callback) {
        calls[ev] = [];
      } else {
        list = calls[ev];
        if (!list) {
          return this;
        }
        for (i = 0, _len = list.length; i < _len; i++) {
          callbackfunction = list[i];
          if (callback === callbackfunction) {
            list.splice(i, 1);
            break;
          }
        }
      }
    }
    return this;
  };
  Element.prototype.makeGesture = function(ev) {
    var callbacFunction, calls, list, _i, _j, _len, _len2;
    if (!(calls = this._callbacks)) {
      return this;
    }
    if (list = calls[ev]) {
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        callbacFunction = list[_i];
        callbacFunction.apply(this, Array.prototype.slice.call(arguments, 1));
      }
    }
    if (list = calls['all']) {
      for (_j = 0, _len2 = list.length; _j < _len2; _j++) {
        callbacFunction = list[_j];
        callbacFunction.apply(this, arguments);
      }
    }
    return this;
  };
  String.prototype.contains = function(it) {
    return this.indexOf(it) !== -1;
  };
  Array.prototype.contains = function(element) {
    var el, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      el = this[_i];
      if (el === element) {
        return true;
      }
    }
    return false;
  };
  Object.merge = function(destination, source) {
    var property;
    for (property in source) {
      if (source.hasOwnProperty(property)) {
        destination[property] = source[property];
      }
    }
    return destination;
  };
  if (typeof jQuery !== "undefined" && jQuery !== null) {
    (function($) {
      $.fn.onGesture = function(eventName, callback) {
        return this.each(function(i, element) {
          return element.onGesture(eventName, callback);
        });
      };
      $.fn.unbindGesture = function(eventName, callback) {
        return this.each(function(i, element) {
          return element.unbindGesture(eventName, callback);
        });
      };
      return $.fn.makeGesture = function(eventName) {
        return this.each(function(i, element) {
          return element.makeGesture(eventName);
        });
      };
    })(jQuery);
  }
  StateMachine = (function() {
    function StateMachine(identifier, router) {
      this.identifier = identifier;
      this.router = router;
      this.currentState = new NoTouch(this);
      this.analyser = new Analyser;
    }
    StateMachine.prototype.apply = function(eventName, eventObj) {
      return this.currentState.apply(eventName, eventObj);
    };
    StateMachine.prototype.setState = function(newState) {
      return this.currentState = newState;
    };
    StateMachine.prototype.getState = function() {
      return this.currentState;
    };
    return StateMachine;
  })();
  GenericState = (function() {
    GenericState.prototype.init = function() {};
    function GenericState(machine) {
      this.machine = machine;
      this.eventObj = this.machine.currentState != null ? this.machine.currentState.eventObj : {};
      this.init();
    }
    GenericState.prototype.apply = function(eventName, arg) {
      Object.merge(this.eventObj, arg);
      return this[eventName]();
    };
    GenericState.prototype.touchstart = function() {};
    GenericState.prototype.touchmove = function() {};
    GenericState.prototype.touchend = function() {};
    GenericState.prototype.notify = function(name) {
      return this.machine.router.broadcast(name, this.eventObj);
    };
    return GenericState;
  })();
  NoTouch = (function() {
    __extends(NoTouch, GenericState);
    function NoTouch() {
      NoTouch.__super__.constructor.apply(this, arguments);
    }
    NoTouch.prototype.touchstart = function() {
      return this.machine.setState(new FirstTouch(this.machine));
    };
    return NoTouch;
  })();
  FirstTouch = (function() {
    __extends(FirstTouch, GenericState);
    function FirstTouch() {
      FirstTouch.__super__.constructor.apply(this, arguments);
    }
    FirstTouch.prototype.init = function() {
      var _machine;
      _machine = this.machine;
      return this.fixedtimer = setTimeout((function() {
        return _machine.setState(new Fixed(_machine));
      }), 300);
    };
    FirstTouch.prototype.touchend = function() {
      clearTimeout(this.fixedtimer);
      this.notify("tap");
      return this.machine.setState(new NoTouch(this.machine));
    };
    FirstTouch.prototype.touchmove = function() {
      clearTimeout(this.fixedtimer);
      this.notify("drag");
      return this.machine.setState(new Drag(this.machine));
    };
    return FirstTouch;
  })();
  Fixed = (function() {
    __extends(Fixed, GenericState);
    function Fixed() {
      Fixed.__super__.constructor.apply(this, arguments);
    }
    Fixed.prototype.init = function() {
      return this.notify("fixed");
    };
    Fixed.prototype.touchend = function() {
      this.notify("fixedend");
      return this.machine.setState(new NoTouch(this.machine));
    };
    return Fixed;
  })();
  Drag = (function() {
    __extends(Drag, GenericState);
    function Drag() {
      Drag.__super__.constructor.apply(this, arguments);
    }
    Drag.prototype.init = function() {
      var that;
      this.isTap = true;
      this.initialX = this.eventObj.clientX;
      this.initialY = this.eventObj.clientY;
      this.delta = 15;
      that = this;
      return setTimeout((function() {
        return that.isTap = false;
      }), 150);
    };
    Drag.prototype.touchmove = function() {
      return this.notify("drag");
    };
    Drag.prototype.touchend = function() {
      if (this.isTap && (Math.abs(this.eventObj.clientX - this.initialX) < this.delta) && (Math.abs(this.eventObj.clientY - this.initialY) < this.delta)) {
        this.notify("tap");
      } else {
        this.notify("dragend");
      }
      return this.machine.setState(new NoTouch(this.machine));
    };
    return Drag;
  })();
  FingerGesture = (function() {
    function FingerGesture(fingerId, gestureName, eventObj) {
      var date;
      this.fingerId = fingerId;
      this.gestureName = gestureName;
      date = new Date();
      this.params = {};
      this.positions = [];
      this.positions[0] = {
        x: eventObj.clientX,
        y: eventObj.clientY,
        time: date.getTime()
      };
      this.positionCount = 0;
      this.params.startX = eventObj.clientX;
      this.params.startY = eventObj.clientY;
      this.params.timeStart = date.getTime();
      this.params.timeElapsed = 0;
      this.params.panX = 0;
      this.params.panY = 0;
      this.params.gestureName = this.gestureName;
      this.updatePosition(eventObj);
      this.params.speed = 0;
      this.params.dragDirection = "unknown";
      this.isFlick = false;
    }
    FingerGesture.prototype.update = function(gestureName, eventObj) {
      var date, movedX, movedY;
      this.gestureName = gestureName;
      this.positionCount++;
      date = new Date();
      this.positions[this.positionCount] = {
        x: eventObj.clientX,
        y: eventObj.clientY,
        time: date.getTime()
      };
      this.params.timeElapsed = date.getTime() - this.params.timeStart;
      this.updatePosition(eventObj);
      if (this.gestureName === "drag") {
        movedX = this.params.x - this.positions[this.positionCount - 1].x;
        movedY = this.params.y - this.positions[this.positionCount - 1].y;
        this.params.speed = Math.sqrt(movedX * movedX + movedY * movedY) / (this.positions[this.positionCount].time - this.positions[this.positionCount - 1].time);
        this.params.dragDirection = getDragDirection(this);
      }
      if (this.gestureName === "dragend") {
        if (this.params.speed > 0.5 || this.params.timeElapsed < 100) {
          return this.isFlick = true;
        }
      }
    };
    FingerGesture.prototype.updatePosition = function(eventObj) {
      this.params.x = eventObj.clientX;
      this.params.y = eventObj.clientY;
      this.params.panX = this.params.x - this.params.startX;
      return this.params.panY = this.params.y - this.params.startY;
    };
    return FingerGesture;
  })();
  EventRouter = (function() {
    function EventRouter(element) {
      this.element = element;
      this.grouper = new EventGrouper();
      this.machines = {};
      this.element.addEventListener("touchstart", __bind(function(event) {
        return this.touchstart(event);
      }, this));
      this.element.addEventListener("touchend", __bind(function(event) {
        return this.touchend(event);
      }, this));
      this.element.addEventListener("touchmove", __bind(function(event) {
        return this.touchmove(event);
      }, this));
    }
    EventRouter.prototype.touchstart = function(event) {
      var i, iMachine, _i, _len, _ref, _results;
      event.preventDefault();
      this.fingerCount = event.touches.length;
      this.grouper.refreshFingerCount(this.fingerCount, this.element);
      _ref = event.changedTouches;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(!this.machines[i.identifier] ? (this.addGlobal(event, i), iMachine = new StateMachine(i.identifier, this), iMachine.apply("touchstart", i), this.machines[i.identifier] = iMachine) : void 0);
      }
      return _results;
    };
    EventRouter.prototype.touchend = function(event) {
      var exists, iMKey, iTouch, _i, _len, _ref;
      event.preventDefault();
      for (iMKey in this.machines) {
        iMKey = parseInt(iMKey);
        exists = false;
        _ref = event.touches;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          iTouch = _ref[_i];
          if (iTouch.identifier === iMKey) {
            exists = true;
          }
        }
        if (!exists && (this.machines[iMKey] != null)) {
          this.machines[iMKey].apply("touchend", this.addGlobal(event, {}));
          delete this.machines[iMKey];
        }
      }
      this.fingerCount = event.touches.length;
      return this.grouper.refreshFingerCount(this.fingerCount, this.element);
    };
    EventRouter.prototype.touchmove = function(event) {
      var i, iMachine, _i, _len, _ref, _results;
      event.preventDefault();
      _ref = event.changedTouches;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        if (!(this.machines[i.identifier] != null)) {
          iMachine = new StateMachine(i.identifier, this);
          iMachine.apply("touchstart", i);
          this.machines[i.identifier] = iMachine;
        }
        this.addGlobal(event, i);
        _results.push(this.machines[i.identifier].apply("touchmove", i));
      }
      return _results;
    };
    EventRouter.prototype.addGlobal = function(event, target) {
      target.global = {};
      return target.global = {
        scale: event.scale,
        rotation: event.rotation,
        event: event
      };
    };
    EventRouter.prototype.broadcast = function(name, eventObj) {
      return this.grouper.receive(name, eventObj, this.fingerCount, this.element);
    };
    return EventRouter;
  })();
  EventGrouper = (function() {
    function EventGrouper() {
      this.savedTap = {};
      this.fixedSave = {};
      this.fingerCount = 0;
    }
    EventGrouper.prototype.refreshFingerCount = function(newCount, element) {
      var i, _results;
      if (newCount === 0) {
        this.fingerCount = -1;
      }
      if (this.fingerCount < newCount) {
        this.fingerCount = newCount;
        this.analyser = new Analyser(this.fingerCount, element);
        _results = [];
        for (i in this.fixedSave) {
          _results.push(this.analyser.notify(this.fixedSave[i].identifier, "fixed", this.fixedSave[i]));
        }
        return _results;
      }
    };
    EventGrouper.prototype.receive = function(name, eventObj, fingerCount, element) {
      var t;
      this.send(name, eventObj);
      if (name === "tap") {
        if (typeof this.first !== 'undefined') {
          t = new Date().getTime() - this.last;
          this.first = false;
        } else {
          this.first = true;
        }
        if (!this.first && t < 300) {
          this.send("doubletap", eventObj);
        } else {
          this.savedTap[eventObj.identifier] = {};
          this.savedTap[eventObj.identifier].event = eventObj;
          this.savedTap[eventObj.identifier].time = new Date().getTime();
        }
        return this.last = new Date().getTime();
      }
    };
    EventGrouper.prototype.send = function(name, eventObj) {
      var i;
      if (name === "fixed") {
        this.fixedSave[eventObj.identifier] = eventObj;
      } else if (name === "fixedend") {
        for (i in this.fixedSave) {
          if (eventObj.identifier === parseInt(i)) {
            delete this.fixedSave[i];
          }
        }
      }
      return this.analyser.notify(eventObj.identifier, name, eventObj);
    };
    return EventGrouper;
  })();
  Object.swap = function(obj1, obj2) {
    var temp;
    temp = obj2;
    obj2 = obj1;
    return obj1 = obj2;
  };
  distanceBetweenTwoPoints = function(x1, y1, x2, y2) {
    return Math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)));
  };
  getDirection = function(deltaX, deltaY) {
    if ((deltaX === deltaY && deltaY === 0)) {
      return "unknown";
    }
    if (Math.abs(deltaX) > Math.abs(deltaY)) {
      if (deltaX < 0) {
        return "left";
      } else {
        return "right";
      }
    } else {
      if (deltaY < 0) {
        return "up";
      } else {
        return "down";
      }
    }
  };
  getDragDirection = function(finger) {
    var deltaX, deltaY;
    deltaX = finger.params.x - finger.positions[finger.positionCount - 1].x;
    deltaY = finger.params.y - finger.positions[finger.positionCount - 1].y;
    return getDirection(deltaX, deltaY);
  };
  digit_name = (function() {
    var names;
    names = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten'];
    return function(n) {
      return names[n];
    };
  })();
  Analyser = (function() {
    function Analyser(totalNbFingers, targetElement) {
      var date;
      this.totalNbFingers = totalNbFingers;
      this.targetElement = targetElement;
      this.fingersArray = {};
      this.fingers = [];
      this.firstAnalysis = true;
      this.informations = {};
      this.informations = {};
      this.informations.fingers = [];
      this.informations.firstTrigger = true;
      date = new Date();
      this.fingerArraySize = 0;
      this.informations.timeStart = date.getTime();
    }
    Analyser.prototype.notify = function(fingerID, gestureName, eventObj) {
      var date, targetTouch, _i, _len, _ref;
      this.eventObj = eventObj;
      this.informations.rotation = this.eventObj.global.rotation;
      this.informations.scale = this.eventObj.global.scale;
      this.informations.targets = [];
      _ref = this.eventObj.global.event.targetTouches;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        targetTouch = _ref[_i];
        this.informations.targets.push(targetTouch.target);
      }
      date = new Date();
      this.informations.timeElapsed = date.getTime() - this.informations.timeStart;
      if (this.fingersArray[fingerID] != null) {
        this.fingersArray[fingerID].update(gestureName, this.eventObj);
      } else {
        this.fingersArray[fingerID] = new FingerGesture(fingerID, gestureName, this.eventObj);
        this.fingers.push(this.fingersArray[fingerID]);
        this.fingerArraySize++;
      }
      if (this.fingerArraySize === this.totalNbFingers) {
        return this.analyse(this.totalNbFingers);
      }
    };
    Analyser.prototype.analyse = function(nbFingers) {
      var finger, _i, _len, _ref;
      if (this.firstAnalysis) {
        this.init();
      }
      this.gestureName = [];
      _ref = this.fingers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        finger = _ref[_i];
        this.gestureName.push(finger.gestureName);
      }
      this.targetElement.makeGesture(this.gestureName, this.informations);
      this.triggerDrag();
      this.triggerFixed();
      this.triggerFlick();
      if (this.informations.firstTrigger) {
        return this.informations.firstTrigger = false;
      }
    };
    Analyser.prototype.init = function() {
      var i, _ref;
      this.fingers = this.fingers.sort(function(a, b) {
        if (Math.abs(a.params.startX - b.params.startX) < 15) {
          return a.params.startY - b.params.startY;
        }
        return a.params.startX - b.params.startX;
      });
      this.informations.nbFingers = this.fingers.length;
      for (i = 0, _ref = this.fingers.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        this.informations.fingers[i] = this.fingers[i].params;
      }
      return this.firstAnalysis = false;
    };
    Analyser.prototype.triggerDrag = function() {
      if (this.gestureName.contains("drag")) {
        this.triggerDragDirections();
        if (this.gestureName.length > 1) {
          this.triggerPinchOrSpread();
          return this.triggerRotation();
        }
      }
    };
    Analyser.prototype.triggerDragDirections = function() {
      var finger, gestureName, _i, _len, _ref;
      gestureName = [];
      _ref = this.fingers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        finger = _ref[_i];
        gestureName.push(finger.params.dragDirection);
      }
      if (!gestureName.contains("unknown")) {
        return this.targetElement.makeGesture(gestureName, this.informations);
      }
    };
    Analyser.prototype.triggerPinchOrSpread = function() {
      var sameDirection;
      sameDirection = false;
      if (this.informations.scale < 1.1 && !sameDirection) {
        this.targetElement.makeGesture("" + (digit_name(this.fingers.length)) + ":pinch", this.informations);
        return this.targetElement.makeGesture("pinch", this.informations);
      } else if (this.informations.scale > 1.1 && !sameDirection) {
        this.targetElement.makeGesture("" + (digit_name(this.fingers.length)) + ":spread", this.informations);
        return this.targetElement.makeGesture("spread", this.informations);
      }
    };
    Analyser.prototype.triggerFixed = function() {
      var dontTrigger, finger, gestureName, _i, _len, _ref;
      if (this.gestureName.length > 1 && this.gestureName.contains("fixed")) {
        dontTrigger = false;
        gestureName = [];
        _ref = this.fingers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          finger = _ref[_i];
          if (finger.gestureName === "drag" && finger.params.dragDirection === "triggerDrag") {
            dontTrigger = true;
            break;
          }
          if (finger.gestureName === "drag") {
            gestureName.push(finger.params.dragDirection);
          } else {
            gestureName.push("fixed");
          }
        }
        if (!dontTrigger) {
          return this.targetElement.makeGesture(gestureName, this.informations);
        }
      }
    };
    Analyser.prototype.triggerFlick = function() {
      var dontTrigger, finger, gestureName1, gestureName2, _i, _len, _ref;
      if (this.gestureName.contains("dragend")) {
        gestureName1 = [];
        gestureName2 = [];
        dontTrigger = false;
        _ref = this.fingers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          finger = _ref[_i];
          if (finger.params.dragDirection === "unknown") {
            dontTrigger = true;
          }
          if (finger.isFlick) {
            gestureName1.push("flick:" + finger.params.dragDirection);
            gestureName2.push("flick");
          } else {
            gestureName1.push(finger.params.dragDirection);
            gestureName2.push(finger.params.dragDirection);
          }
        }
        if (!dontTrigger) {
          this.targetElement.makeGesture(gestureName1, this.informations);
          return this.targetElement.makeGesture(gestureName2, this.informations);
        }
      }
    };
    Analyser.prototype.triggerRotation = function() {
      var rotationDirection;
      if (!(this.lastRotation != null)) {
        this.lastRotation = this.informations.rotation;
      }
      rotationDirection = "";
      if (this.informations.rotation > this.lastRotation) {
        rotationDirection = "rotate:cw";
      } else {
        rotationDirection = "rotate:ccw";
      }
      this.targetElement.makeGesture(rotationDirection, this.informations);
      this.targetElement.makeGesture("rotate", this.informations);
      this.targetElement.makeGesture("" + (digit_name(this.fingers.length)) + ":" + rotationDirection, this.informations);
      return this.targetElement.makeGesture("" + (digit_name(this.fingers.length)) + ":rotate", this.informations);
    };
    return Analyser;
  })();
}).call(this);
