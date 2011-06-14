(function() {
  /*
   The unbind and trigger function have been taken from Backbone Framework. 
   The onGesture function is inspired by the bind functon of Backbone Framework. 
  */  var $, Analyser, Drag, EventGrouper, EventRouter, FingerGesture, FirstTouch, Fixed, GenericState, NoTouch, StateMachine, digit_name, distanceBetweenTwoPoints, getDirection, getDragDirection;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
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
    var calls, i, list, _i, _len;
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
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          i = list[_i];
          if (callback === list[i]) {
            list.splice(i, 1);
            break;
          }
        }
      }
    }
    return this;
  };
  Element.prototype.trigger = function(ev) {
    var calls, i, list, _i, _j, _len, _len2;
    if (!(calls = this._callbacks)) {
      return this;
    }
    if (list = calls[ev]) {
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        i = list[_i];
        i.apply(this, Array.prototype.slice.call(arguments, 1));
      }
    }
    if (list = calls['all']) {
      for (_j = 0, _len2 = list.length; _j < _len2; _j++) {
        i = list[_j];
        i.apply(this, arguments);
      }
    }
    return this;
  };
  $ = function(element) {
    return document.getElementById(element);
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
  
function dump(arr) {
		var dumped_text = "["
		for(var item in arr) {
			var value = arr[item];
			if(typeof(value)=='function')
				continue;
			else if(typeof(value)=='object')
				dumped_text += dump(value);
			else
				dumped_text += item + "=" + value + " ";
		}
	return dumped_text + "]";
}
function print_r(obj) {
  win_print_r = window.open('about:blank', 'win_print_r');
  win_print_r.document.write('<html><body>');
  r_print_r(obj, win_print_r);
  win_print_r.document.write('</body></html>');
 }

 function r_print_r(theObj, win_print_r) {
  if(theObj.constructor == Array ||
   theObj.constructor == Object){
   if (win_print_r == null)
    win_print_r = window.open('about:blank', 'win_print_r');
   }
   for(var p in theObj){
    if(theObj[p].constructor == Array||
     theObj[p].constructor == Object){
     win_print_r.document.write("<li>["+p+"] =>"+typeof(theObj)+"</li>");
     win_print_r.document.write("<ul>")
     r_print_r(theObj[p], win_print_r);
     win_print_r.document.write("</ul>")
    } else {
     win_print_r.document.write("<li>["+p+"] =>"+theObj[p]+"</li>");
    }
   }
  win_print_r.document.write("</ul>")
 }


Object.keys = function (object)
{
  var keys = [];
  for(var i in object) if (object.hasOwnProperty(i))
  {
    keys.push(i);
  }
  return keys;
}


Object.merge = function(destination, source) {
    for (var property in source) {
        if (source.hasOwnProperty(property)) {
            destination[property] = source[property];
        }
    }
    return destination;
}
;
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
      this.fixedtimer = setTimeout((function() {
        return _machine.setState(new Fixed(_machine));
      }), 300);
      this.eventObj.initX = this.eventObj.clientX;
      return this.eventObj.initY = this.eventObj.clientY;
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
      this.delta = 25;
      that = this;
      return setTimeout((function() {
        return that.isTap = false;
      }), 75);
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
      this.params.timeElasped = 0;
      this.params.panX = 0;
      this.params.panY = 0;
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
      this.params.timeElasped = date.getTime() - this.params.timeStart;
      this.updatePosition(eventObj);
      if (this.gestureName === "drag") {
        movedX = this.params.x - this.positions[this.positionCount - 1].x;
        movedY = this.params.y - this.positions[this.positionCount - 1].y;
        this.params.speed = Math.sqrt(movedX * movedX + movedY * movedY) / (this.positions[this.positionCount].time - this.positions[this.positionCount - 1].time);
        this.params.dragDirection = getDragDirection(this);
      }
      if (this.gestureName === "dragend") {
        if (this.params.speed > 0.5 || this.params.timeElasped < 100) {
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
      var that;
      this.element = element;
      this.grouper = new EventGrouper;
      this.machines = {};
      that = this;
      this.element.addEventListener("touchstart", function(event) {
        return that.touchstart(event);
      });
      this.element.addEventListener("touchend", function(event) {
        return that.touchend(event);
      });
      this.element.addEventListener("touchmove", function(event) {
        return that.touchmove(event);
      });
    }
    EventRouter.prototype.touchstart = function(event) {
      var a, i, iMachine, z, _i, _len, _ref, _results;
      event.preventDefault();
      this.fingerCount = event.touches.length;
      this.grouper.refreshFingerCount(this.fingerCount, this.element);
      a = (function() {
        var _i, _len, _ref, _results;
        _ref = event.touches;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          z = _ref[_i];
          _results.push(z.identifier + " ");
        }
        return _results;
      })();
      $('debug').innerHTML = a + $('debug').innerHTML + "<br/>\n";
      _ref = event.changedTouches;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(!(this.machines[i.identifier] != null) ? (this.addGlobal(event, i), iMachine = new StateMachine(i.identifier, this), iMachine.apply("touchstart", i), this.machines[i.identifier] = iMachine) : void 0);
      }
      return _results;
    };
    EventRouter.prototype.touchend = function(event) {
      var exists, iMKey, iTouch, _i, _j, _len, _len2, _ref, _ref2;
      event.preventDefault();
      _ref = Object.keys(this.machines);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        iMKey = _ref[_i];
        iMKey = parseInt(iMKey);
        exists = false;
        _ref2 = event.touches;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          iTouch = _ref2[_j];
          if (iTouch.identifier === iMKey) {
            exists = true;
          }
        }
        if (!exists) {
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
        rotation: event.rotation
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
      var i, _i, _len, _ref, _results;
      if (newCount === 0) {
        this.fingerCount = -1;
      }
      if (this.fingerCount < newCount) {
        this.fingerCount = newCount;
        this.analyser = new Analyser(this.fingerCount, element);
        $('debug').innerHTML = ("/new " + this.fingerCount + "/\n") + $('debug').innerHTML;
        _ref = Object.keys(this.fixedSave);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(this.analyser.notify(this.fixedSave[i].identifier, "fixed", this.fixedSave[i]));
        }
        return _results;
      }
    };
    EventGrouper.prototype.receive = function(name, eventObj, fingerCount, element) {
      this.send(name, eventObj);
      if (name === "tap") {
        if ((this.savedTap[eventObj.identifier] != null) && ((new Date().getTime()) - this.savedTap[eventObj.identifier].time) < 400) {
          $('debug').innerHTML = "/doubletap/\n" + $('debug').innerHTML;
          return this.send("doubletap", eventObj);
        } else {
          this.savedTap[eventObj.identifier] = {};
          this.savedTap[eventObj.identifier].event = eventObj;
          return this.savedTap[eventObj.identifier].time = new Date().getTime();
        }
      }
    };
    EventGrouper.prototype.send = function(name, eventObj) {
      var i, _i, _len, _ref;
      if (name === "fixed") {
        this.fixedSave[eventObj.identifier] = eventObj;
      } else if (name === "fixedend") {
        _ref = Object.keys(this.fixedSave);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
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
    /*
    	direction = Math.atan2(deltaX, deltaY)
    	pi = Math.PI
    	if (pi / 4) > direction > (3 * (pi / 4))
    		return "right"
    	if (3 * (pi / 4)) > direction > - (3 * (pi / 4))
    		return "up"
    	if (3 * (pi / 4)) < direction < (3 * (pi / 4))
    		return "left"
    	if (pi / 4) > direction > - (pi / 4)
    		return "down"
    	return "-"
    	
    */    if ((deltaX === deltaY && deltaY === 0)) {
      return "unknownDirection";
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
  /*
  	if deltaX > 0 and deltaY < 0 ## Right top side of the circle
  		if Math.abs(deltaX) > Math.abs(deltaY) then return "right" else return "up"
  	if deltaX > 0 and deltaY > 0 ## Right bottom side of the circle
  		if Math.abs(deltaX) > Math.abs(deltaY) then return "right" else return "down"
  	if deltaX < 0 and deltaY < 0 ## Left top side of the circle
  		if Math.abs(deltaX) > Math.abs(deltaY) then return "left" else return "up"
  	if deltaX < 0 and deltaY > 0 ## Left top side of the circle
  		if Math.abs(deltaX) > Math.abs(deltaY) then return "left" else return "down"
  	return "diagonal"
  */
  getDragDirection = function(finger) {
    var deltaX, deltaY;
    deltaX = finger.params.x - finger.positions[finger.positionCount - 1].x;
    deltaY = finger.params.y - finger.positions[finger.positionCount - 1].y;
    return getDirection(deltaX, deltaY);
  };
  digit_name = (function() {
    var names;
    names = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'height', 'nine', 'ten'];
    return function(n) {
      return names[n];
    };
  })();
  Analyser = (function() {
    function Analyser(totalNbFingers, targetElement) {
      this.totalNbFingers = totalNbFingers;
      this.targetElement = targetElement;
      this.fingersArray = {};
      this.fingers = [];
      this.firstAnalysis = true;
      this.informations = {};
      this.informations.global = {};
    }
    Analyser.prototype.notify = function(fingerID, gestureName, eventObj) {
      this.eventObj = eventObj;
      $('debug').innerHTML = ("/notify " + gestureName + "/\n") + $('debug').innerHTML;
      this.informations.global.rotation = this.eventObj.global.rotation;
      this.informations.global.scale = this.eventObj.global.scale;
      if (this.fingersArray[fingerID] != null) {
        this.fingersArray[fingerID].update(gestureName, this.eventObj);
      } else {
        $('debug').innerHTML = "/newgesture/\n" + $('debug').innerHTML;
        this.fingersArray[fingerID] = new FingerGesture(fingerID, gestureName, this.eventObj);
        this.fingers.push(this.fingersArray[fingerID]);
      }
      if (_.size(this.fingersArray) === this.totalNbFingers) {
        return this.analyse(this.totalNbFingers);
      }
    };
    Analyser.prototype.analyse = function(nbFingers) {
      if (this.firstAnalysis) {
        this.init();
      }
      switch (nbFingers) {
        case 1:
          return this.oneFingerGesture(this.fingersArray);
        case 2:
          return this.twoFingersGesture(this.fingersArray);
        case 3:
          return this.threeFingersGesture(this.fingersArray);
        case 4:
          return this.fourFingersGesture(this.fingersArray);
        case 5:
          return this.fiveFingersGesture(this.fingersArray);
        default:
          throw "We do not analyse more than 5 fingers";
      }
    };
    /*----------------------------------------------------------------------------------------------------------------
    	## One Finger Gesture
    	*/
    Analyser.prototype.oneFingerGesture = function() {
      var eventName, gestureName, toTrigger, _i, _len, _results;
      toTrigger = [];
      gestureName = this.fingers[0].gestureName;
      this.generateGrouppedFingerName();
      switch (gestureName) {
        case "fixedend":
          this.informations.global.type = "press";
          break;
        case "dragend":
          if (this.fingers[0].isFlick) {
            toTrigger.push("flick");
            toTrigger.push("flick:" + this.fingers[0].params.dragDirection);
          }
          break;
        case "drag":
          this.triggerDragDirections();
      }
      this.targetElement.trigger(gestureName, this.informations);
      if (toTrigger.length > 0) {
        _results = [];
        for (_i = 0, _len = toTrigger.length; _i < _len; _i++) {
          eventName = toTrigger[_i];
          _results.push(this.targetElement.trigger(eventName, this.informations));
        }
        return _results;
      }
    };
    /*----------------------------------------------------------------------------------------------------------------
    	## Two Finger Gesture
    	*/
    Analyser.prototype.twoFingersGesture = function() {
      var eventName, gestureName, toTrigger, _i, _len, _results;
      gestureName = "" + this.fingers[0].gestureName + "," + this.fingers[1].gestureName;
      toTrigger = [];
      this.generateGrouppedFingerName();
      this.informations.global.distance = distanceBetweenTwoPoints(this.fingers[0].params.x, this.fingers[0].params.y, this.fingers[1].params.x, this.fingers[1].params.y);
      this.triggerFixed();
      switch (gestureName) {
        case "fixedend,fixedend":
          toTrigger.push("press,press");
          break;
        case "fixed,drag":
          toTrigger.push("fixed," + this.fingers[1].params.dragDirection);
          break;
        case "drag,fixed":
          toTrigger.push("" + this.fingers[0].params.dragDirection + ",fixed");
          break;
        case "dragend,dragend":
          if (this.fingers[0].isFlick && this.fingers[1].isFlick) {
            toTrigger.push("flick,flick");
          }
          break;
        case "dragend,drag":
        case "drag,dragend":
          if (this.fingers[0].isFlick) {
            toTrigger.push("flick," + this.fingers[1].params.dragDirection);
            toTrigger.push("flick:" + this.fingers[0].params.dragDirection + "," + this.fingers[1].params.dragDirection);
          } else if (this.fingers[1].isFlick) {
            toTrigger.push("" + this.fingers[0].params.dragDirection + ",flick");
            toTrigger.push("" + this.fingers[0].params.dragDirection + ",flick:" + this.fingers[1].params.dragDirection);
          }
          break;
        case "drag,drag":
          this.triggerPinchOrSpread();
          this.triggerRotation();
          this.triggerDragDirections();
      }
      this.targetElement.trigger(gestureName, this.informations);
      if (toTrigger.length > 0) {
        _results = [];
        for (_i = 0, _len = toTrigger.length; _i < _len; _i++) {
          eventName = toTrigger[_i];
          _results.push(this.targetElement.trigger(eventName, this.informations));
        }
        return _results;
      }
    };
    /*----------------------------------------------------------------------------------------------------------------
    	## Three Finger Gesture
    	*/
    Analyser.prototype.threeFingersGesture = function() {
      var dragIndex, eventName, finger, fixedIndex, gestureName, i, toTrigger, type, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _results;
      gestureName = "" + this.fingers[0].gestureName + "," + this.fingers[1].gestureName + "," + this.fingers[2].gestureName;
      toTrigger = [];
      this.generateGrouppedFingerName();
      this.triggerFixed();
      switch (gestureName) {
        case "fixedend,fixedend,fixedend":
          toTrigger.push("press,press,press");
          break;
        case "fixed,fixed,drag":
        case "fixed,drag,fixed":
        case "drag,fixed,fixed":
          type = "";
          i = dragIndex = 0;
          _ref = this.fingers;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            finger = _ref[_i];
            if (finger.gestureName === "drag") {
              type += finger.params.dragDirection;
              dragIndex = i;
            } else {
              type += finger.gestureName;
            }
            i++;
            if (i < this.fingers.length) {
              type += ",";
            }
          }
          toTrigger.push(type);
          switch (dragIndex) {
            case 0:
              toTrigger.push("drag,fixed,fixed");
              break;
            case 1:
              toTrigger.push("fixed,drag,fixed");
              break;
            case 2:
              toTrigger.push("fixed,fixed,drag");
          }
          break;
        case "fixed,drag,drag":
        case "drag,fixed,drag":
        case "drag,drag,fixed":
          type = "";
          i = fixedIndex = 0;
          _ref2 = this.fingers;
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            finger = _ref2[_j];
            if (finger.gestureName === "drag") {
              type += finger.params.dragDirection;
            } else {
              type += finger.gestureName;
              fixedIndex = i;
            }
            i++;
            if (i < this.fingers.length) {
              type += ",";
            }
          }
          toTrigger.push(type);
          switch (fixedIndex) {
            case 0:
              toTrigger.push("fixed,drag,drag");
              break;
            case 1:
              toTrigger.push("drag,fixed,drag");
              break;
            case 2:
              toTrigger.push("drag,drag,fixed");
          }
          toTrigger.push("two:drag,fixed");
          toTrigger.push("fixed,two:drag");
          break;
        case "drag,drag,drag":
          this.triggerPinchOrSpread();
          this.triggerRotation();
          this.triggerDragDirections();
      }
      this.targetElement.trigger(gestureName, this.informations);
      if (toTrigger.length > 0) {
        _results = [];
        for (_k = 0, _len3 = toTrigger.length; _k < _len3; _k++) {
          eventName = toTrigger[_k];
          _results.push(this.targetElement.trigger(eventName, this.informations));
        }
        return _results;
      }
    };
    /*----------------------------------------------------------------------------------------------------------------
    	## Four Finger Gesture
    	*/
    Analyser.prototype.fourFingersGesture = function() {
      var eventName, gestureName, toTrigger, _i, _len, _results;
      this.generateGrouppedFingerName();
      this.triggerFixed();
      toTrigger = [];
      gestureName = "" + this.fingers[0].gestureName + "," + this.fingers[1].gestureName + "," + this.fingers[2].gestureName + "," + this.fingers[3].gestureName;
      switch (gestureName) {
        case "fixedend,fixedend,fixedend,fixedend":
          toTrigger.push("press,press,press,press");
          break;
        case "drag,drag,drag,drag":
          this.triggerPinchOrSpread();
          this.triggerRotation();
          this.triggerDragDirections();
      }
      this.targetElement.trigger(gestureName, this.informations);
      if (toTrigger.length > 0) {
        _results = [];
        for (_i = 0, _len = toTrigger.length; _i < _len; _i++) {
          eventName = toTrigger[_i];
          _results.push(this.targetElement.trigger(eventName, this.informations));
        }
        return _results;
      }
    };
    /*----------------------------------------------------------------------------------------------------------------
    	## Five Finger Gesture
    	*/
    Analyser.prototype.fiveFingersGesture = function() {
      var eventName, gestureName, toTrigger, _i, _len, _results;
      this.generateGrouppedFingerName();
      this.triggerFixed();
      toTrigger = [];
      gestureName = "" + this.fingers[0].gestureName + "," + this.fingers[1].gestureName + "," + this.fingers[2].gestureName + "," + this.fingers[3].gestureName + "," + this.fingers[4].gestureName;
      switch (gestureName) {
        case "fixedend,fixedend,fixedend,fixedend,fixedend":
          toTrigger.push("press,press,press,press,press");
          break;
        case "drag,drag,drag,drag,drag":
          this.triggerPinchOrSpread();
          this.triggerRotation();
          this.triggerDragDirections();
      }
      this.targetElement.trigger(gestureName, this.informations);
      if (toTrigger.length > 0) {
        _results = [];
        for (_i = 0, _len = toTrigger.length; _i < _len; _i++) {
          eventName = toTrigger[_i];
          _results.push(this.targetElement.trigger(eventName, this.informations));
        }
        return _results;
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
      this.informations.global.nbFingers = this.fingers.length;
      for (i = 0, _ref = this.fingers.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        switch (i) {
          case 0:
            this.informations.first = this.fingers[0].params;
            break;
          case 1:
            this.informations.second = this.fingers[1].params;
            break;
          case 2:
            this.informations.third = this.fingers[2].params;
            break;
          case 3:
            this.informations.fourth = this.fingers[3].params;
            break;
          case 4:
            this.informations.fifth = this.fingers[4].params;
        }
      }
      return this.firstAnalysis = false;
    };
    Analyser.prototype.triggerFixed = function() {
      var dontTrigger, finger, finished, gestureName, _i, _j, _len, _len2, _ref, _ref2;
      finished = true;
      _ref = this.fingers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        finger = _ref[_i];
        if (finger.gestureName === "fixed") {
          finished = false;
        }
      }
      if (!finished) {
        dontTrigger = false;
        gestureName = [];
        _ref2 = this.fingers;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          finger = _ref2[_j];
          if (finger.params.dragDirection !== "unknown") {
            dontTrigger = true;
          }
          if (finger.gestureName === "drag") {
            gestureName.push("" + finger.params.dragDirection);
          } else {
            gestureName.push(finger.params.dragDirection);
          }
        }
        if (!dontTrigger) {
          return this.targetElement.trigger(gestureName, this.informations);
        }
      }
    };
    Analyser.prototype.triggerFlick = function() {
      var dontTrigger, finger, finished, gestureName1, gestureName2, _i, _j, _len, _len2, _ref, _ref2;
      finished = true;
      _ref = this.fingers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        finger = _ref[_i];
        if (finger.gestureName === "dragend") {
          finished = false;
        }
      }
      if (!finished) {
        gestureName1 = [];
        gestureName2 = [];
        dontTrigger = false;
        _ref2 = this.fingers;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          finger = _ref2[_j];
          if (finger.params.dragDirection !== "unknown") {
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
          this.targetElement.trigger(gestureName1, this.informations);
          return this.targetElement.trigger(gestureName2, this.informations);
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
        return this.targetElement.trigger(gestureName, this.informations);
      }
    };
    Analyser.prototype.triggerRotation = function() {
      var rotationDirection;
      if (!(this.lastRotation != null)) {
        this.lastRotation = this.informations.global.rotation;
      }
      rotationDirection = "";
      if (this.informations.global.rotation > this.lastRotation) {
        rotationDirection = "rotate:cw";
      } else {
        rotationDirection = "rotate:ccw";
      }
      this.lastRotation = this.informations.global.rotation;
      this.targetElement.trigger(rotationDirection, this.informations);
      return this.targetElement.trigger("rotate", this.informations);
    };
    Analyser.prototype.triggerPinchOrSpread = function() {
      if (this.informations.global.scale < 1) {
        this.targetElement.trigger("" + (digit_name(this.fingers.length)) + ":pinch", this.informations);
        return this.targetElement.trigger("pinch", this.informations);
      } else if (this.informations.global.scale > 1) {
        this.targetElement.trigger("" + (digit_name(this.fingers.length)) + ":spread", this.informations);
        return this.targetElement.trigger("spread", this.informations);
      }
    };
    Analyser.prototype.generateGrouppedFingerName = function() {
      var finger, gesture, gestureDirection, gestureName, gestureNameDrag, gestures, i, nbFingers, _i, _j, _len, _len2, _ref, _ref2;
      gestureName = [];
      gestureNameDrag = [];
      i = 0;
      nbFingers = this.fingers.length;
      gestures = {
        tap: {
          n: 0,
          fingers: []
        },
        doubletap: {
          n: 0,
          fingers: []
        },
        fixed: {
          n: 0,
          fingers: []
        },
        fixedend: {
          n: 0,
          fingers: []
        },
        drag: {
          n: 0,
          fingers: []
        },
        dragend: {
          n: 0,
          fingers: []
        },
        dragDirection: {
          up: {
            n: 0,
            fingers: []
          },
          down: {
            n: 0,
            fingers: []
          },
          left: {
            n: 0,
            fingers: []
          },
          right: {
            n: 0,
            fingers: []
          },
          drag: {
            n: 0,
            fingers: []
          }
        }
      };
      _ref = this.fingers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        finger = _ref[_i];
        switch (finger.gestureName) {
          case "tap":
            gestures.tap.n++;
            gestures.tap.fingers.push(finger);
            break;
          case "doubletap":
            gestures.doubletap.n++;
            gestures.doubletap.fingers.push(finger);
            break;
          case "fixed":
            gestures.fixed.n++;
            gestures.fixed.fingers.push(finger);
            break;
          case "fixedend":
            gestures.fixedend.n++;
            gestures.fixedend.fingers.push(finger);
            break;
          case "dragend":
            gestures.dragend.n++;
            gestures.dragend.fingers.push(finger);
            break;
          case "drag":
            gestures.drag.n++;
            gestures.drag.fingers.push(finger);
            switch (finger.params.dragDirection) {
              case "up":
                gestures.dragDirection.up.n++;
                gestures.dragDirection.up.fingers.push(finger);
                break;
              case "down":
                gestures.dragDirection.down.n++;
                gestures.dragDirection.down.fingers.push(finger);
                break;
              case "right":
                gestures.dragDirection.right.n++;
                gestures.dragDirection.right.fingers.push(finger);
                break;
              case "left":
                gestures.dragDirection.left.n++;
                gestures.dragDirection.left.fingers.push(finger);
            }
        }
      }
      for (gesture in gestures) {
        if (gestures[gesture].n > 0) {
          if (gesture === "dragend") {
            _ref2 = gestures[gesture].fingers;
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              finger = _ref2[_j];
              if (finger.isFlick) {
                gestureName.push("" + (digit_name(gestures[gesture].n)) + ":flick");
                gestureNameDrag.push("" + (digit_name(gestures[gesture].n)) + ":flick:" + finger.params.dragDirection);
                break;
              }
            }
          } else if (gesture === "fixedend") {
            gestureName.push("" + (digit_name(gestures[gesture].n)) + ":press");
          } else {
            gestureName.push("" + (digit_name(gestures[gesture].n)) + ":" + gesture);
          }
        }
        if (gesture === "dragDirection") {
          for (gestureDirection in gestures[gesture]) {
            if (gestures[gesture][gestureDirection].n > 0) {
              gestureNameDrag.push("" + (digit_name(gestures[gesture][gestureDirection].n)) + ":" + gestureDirection);
            }
          }
        }
      }
      if (gestureNameDrag.length > 0) {
        this.targetElement.trigger(gestureName, this.informations);
      }
      if (gestureNameDrag.length > 0) {
        return this.targetElement.trigger(gestureNameDrag, this.informations);
      }
    };
    return Analyser;
  })();
  window.onload = function() {
    return $("blue").onGesture("all", function(name, event) {
      return $('debug').innerHTML = ("" + name + "<br />") + $('debug').innerHTML;
    });
  };
}).call(this);
