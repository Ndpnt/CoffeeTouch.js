(function() {
  /*
   The bind, unbind and trigger function have been taken from Backbone Framework.
   The bind function has been changed
  */  var $, Analyser, Drag, EventGrouper, EventRouter, FingerGesture, FirstTouch, Fixed, GenericState, NoTouch, StateMachine, distanceBetweenTwoPoints, getDirection, getDragDirection;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Element.prototype.bind = function(eventName, callback) {
    var calls, list;
    if (!(this.router != null)) {
      this.router = new EventRouter(this);
    }
    calls = this._callbacks || (this._callbacks = {});
    list = this._callbacks[eventName] || (this._callbacks[eventName] = []);
    list.push(callback);
    return this;
  };
  Element.prototype.unbind = function(ev, callback) {
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
  
Element.prototype.trigger =  function(ev) {
	  var list, calls, i, l;
	  if (!(calls = this._callbacks)) return this;
	  if (list = calls[ev]) {
	    for (i = 0, l = list.length; i < l; i++) {
	      list[i].apply(this, Array.prototype.slice.call(arguments, 1));
	    }
	  }
	  if (list = calls['all']) {
	    for (i = 0, l = list.length; i < l; i++) {
	      list[i].apply(this, arguments);
	    }
	  }
	  return this;
	};
;
  $ = function(element) {
    return document.getElementById(element);
  };
  
function dump(arr,level) {
		var dumped_text = "["
		for(var item in arr) {
			var value = arr[item];
			if(typeof(value)=='function') continue;
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

Object.prototype.keys = function ()
{
  var keys = [];
  for(var i in this) if (this.hasOwnProperty(i))
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
    GenericState.prototype.description = function() {
      return "Generic state";
    };
    GenericState.prototype.init = function() {};
    function GenericState(machine) {
      this.machine = machine;
      if (this.machine.currentState != null) {
        this.eventObj = this.machine.currentState.eventObj;
      } else {
        this.eventObj = {};
      }
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
    function NoTouch() {
      NoTouch.__super__.constructor.apply(this, arguments);
    }
    __extends(NoTouch, GenericState);
    NoTouch.prototype.description = function() {
      return "NoTouch state";
    };
    NoTouch.prototype.touchstart = function() {
      return this.machine.setState(new FirstTouch(this.machine));
    };
    return NoTouch;
  })();
  FirstTouch = (function() {
    function FirstTouch() {
      FirstTouch.__super__.constructor.apply(this, arguments);
    }
    __extends(FirstTouch, GenericState);
    FirstTouch.prototype.description = function() {
      return "FirstTouch state";
    };
    FirstTouch.prototype.init = function() {
      var _machine;
      _machine = this.machine;
      this.fixedtimer = setTimeout((function() {
        return _machine.setState(new Fixed(_machine));
      }), 500);
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
    function Fixed() {
      Fixed.__super__.constructor.apply(this, arguments);
    }
    __extends(Fixed, GenericState);
    Fixed.prototype.description = function() {
      return "Fixed state";
    };
    Fixed.prototype.init = function() {
      return this.notify("fixed");
    };
    Fixed.prototype.touchend = function() {
      return this.notify("fixedend");
    };
    return Fixed;
  })();
  Drag = (function() {
    function Drag() {
      Drag.__super__.constructor.apply(this, arguments);
    }
    __extends(Drag, GenericState);
    Drag.prototype.description = function() {
      return "Drag state";
    };
    Drag.prototype.init = function() {
      var that;
      this.isTap = true;
      this.initialX = this.eventObj.clientX;
      this.initialY = this.eventObj.clientY;
      this.delta = 25;
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
      this.positions[0] = {};
      this.positionCount = 0;
      this.params.startX = this.positions[0].x = eventObj.clientX;
      this.params.startY = this.positions[0].y = eventObj.clientY;
      this.params.timeStart = date.getTime();
      this.params.timeElasped = 0;
      this.params.panX = 0;
      this.params.panY = 0;
      this.updatePosition(eventObj);
    }
    FingerGesture.prototype.update = function(gestureName, eventObj) {
      var date;
      this.gestureName = gestureName;
      this.positionCount++;
      this.positions[this.positionCount] = {};
      this.positions[this.positionCount].x = eventObj.clientX;
      this.positions[this.positionCount].y = eventObj.clientY;
      date = new Date();
      this.params.timeElasped = date.getTime() - this.params.timeStart;
      if (this.gestureName === "drag") {
        this.params.dragDirection = getDragDirection(this);
      }
      return this.updatePosition(eventObj);
    };
    FingerGesture.prototype.updatePosition = function(eventObj) {
      this.params.x = eventObj.clientX;
      this.params.y = eventObj.clientY;
      this.params.panX = this.params.startX - this.params.x;
      return this.params.panY = this.params.startY - this.params.y;
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
      var i, iMachine, _i, _len, _ref, _results;
      event.preventDefault();
      this.fingerCount = event.touches.length;
      this.grouper.refreshFingerCount(this.fingerCount, this.element);
      _ref = event.changedTouches;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(!(this.machines[i.identifier] != null) ? (iMachine = new StateMachine(i.identifier, this), iMachine.apply("touchstart", i), this.machines[i.identifier] = iMachine) : void 0);
      }
      return _results;
    };
    EventRouter.prototype.touchend = function(event) {
      var exists, iMKey, iTouch, _i, _j, _len, _len2, _ref, _ref2;
      event.preventDefault();
      _ref = this.machines.keys();
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
          this.machines[iMKey].apply("touchend", {});
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
        _results.push(this.machines[i.identifier].apply("touchmove", i));
      }
      return _results;
    };
    EventRouter.prototype.broadcast = function(name, eventObj) {
      return this.grouper.receive(name, eventObj, this.fingerCount, this.element);
    };
    return EventRouter;
  })();
  EventGrouper = (function() {
    function EventGrouper() {
      this.savedTap = {};
    }
    EventGrouper.prototype.refreshFingerCount = function(newCount, element) {
      if (this.fingerCount !== newCount) {
        this.fingerCount = newCount;
        return this.analyser = new Analyser(this.fingerCount, element);
      }
    };
    EventGrouper.prototype.receive = function(name, eventObj, fingerCount, element) {
      if (name === "tap") {
        if ((this.savedTap[eventObj.identifier] != null) && ((new Date().getTime()) - this.savedTap[eventObj.identifier].time) < 400) {
          this.send("doubleTap", eventObj);
        } else {
          this.savedTap[eventObj.identifier] = {};
          this.savedTap[eventObj.identifier].event = eventObj;
          this.savedTap[eventObj.identifier].time = new Date().getTime();
        }
      }
      return this.send(name, eventObj);
    };
    EventGrouper.prototype.send = function(name, eventObj) {
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
    if (finger.positionCount < 4) {
      deltaX = finger.params.x - finger.startX;
      deltaY = finger.params.y - finger.startY;
    } else {
      deltaX = finger.params.x - finger.positions[finger.positionCount - 4].x;
      deltaY = finger.params.y - finger.positions[finger.positionCount - 4].y;
    }
    return getDirection(deltaX, deltaY);
  };
  Analyser = (function() {
    function Analyser(totalNbFingers, targetElement) {
      this.totalNbFingers = totalNbFingers;
      this.targetElement = targetElement;
      this.fingersArray = {};
      this.fingers = [];
      this.firstAnalysis = true;
    }
    Analyser.prototype.notify = function(fingerID, gestureName, eventObj) {
      this.eventObj = eventObj;
      if (this.fingersArray[fingerID] != null) {
        this.fingersArray[fingerID].update(gestureName, this.eventObj);
      } else {
        this.fingersArray[fingerID] = new FingerGesture(fingerID, gestureName, this.eventObj);
        this.fingers.push(this.fingersArray[fingerID]);
      }
      if (_.size(this.fingersArray) === this.totalNbFingers) {
        return this.analyse(this.totalNbFingers);
      }
    };
    Analyser.prototype.analyse = function(nbFingers) {
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
          return this.fiveFingersGeture(this.fingersArray);
        default:
          throw "We do not analyse more than 5 fingers";
      }
    };
    /*----------------------------------------------------------------------------------------------------------------
    	## One Finger Gesture
    	*/
    Analyser.prototype.oneFingerGesture = function() {
      var finger, key;
      for (key in this.fingersArray) {
        if (this.fingersArray.hasOwnProperty(key)) {
          finger = this.fingersArray[key];
        }
      }
      this.informations = {
        first: finger.params,
        global: {}
      };
      switch (finger.gestureName) {
        case "tap":
          this.informations.global.type = "tap";
          break;
        case "doubletap":
          this.informations.global.type = "doubletap";
          break;
        case "fixed":
          this.informations.global.type = "fixed";
          break;
        case "fixedend":
          this.informations.global.type = "press";
          break;
        case "drag":
          this.informations.global.type = finger.params.dragDirection;
          break;
        case "dragend":
          this.informations.global.type = "dragend";
          break;
        default:
          this.informations.global.type = finger.gestureName;
      }
      return this.targetElement.trigger(this.informations.global.type, this.informations);
    };
    /*----------------------------------------------------------------------------------------------------------------
    	## Two Finger Gesture
    	*/
    Analyser.prototype.twoFingersGesture = function() {
      var a1, a2, b1, b2, gestureName, i, key, type;
      i = 0;
      gestureName = "";
      if (this.firstAnalysis) {
        for (key in this.fingersArray) {
          if (this.fingersArray.hasOwnProperty(key)) {
            i++;
            if (i === 1) {
              this.firstFinger = this.fingersArray[key];
            }
            if (i === 2) {
              this.secondFinger = this.fingersArray[key];
            }
          }
        }
        if (Math.abs(this.secondFinger.params.startX - this.firstFinger.params.startX) < 20) {
          if (this.firstFinger.params.startY > this.secondFinger.params.startY) {
            Object.swap(this.firstFinger, this.secondFinger);
          }
        } else if (this.firstFinger.params.startX > this.secondFinger.params.startX) {
          Object.swap(this.firstFinger, this.secondFinger);
        }
        this.informations = {
          first: this.firstFinger.params,
          second: this.secondFinger.params,
          global: {
            scale: 1,
            initialDistance: distanceBetweenTwoPoints(this.firstFinger.params.startX, this.firstFinger.params.startY, this.secondFinger.params.startX, this.secondFinger.params.startY)
          }
        };
        this.informations.global.distance = distanceBetweenTwoPoints(this.firstFinger.params.x, this.firstFinger.params.y, this.secondFinger.params.x, this.secondFinger.params.y);
        this.firstAnalysis = false;
      }
      gestureName = this.firstFinger.gestureName + "," + this.secondFinger.gestureName;
      switch (gestureName) {
        case "tap,tap":
          this.informations.global.type = "tap,tap";
          this.targetElement.trigger("two:tap", this.informations);
          break;
        case "doubletap,doubletap":
          this.informations.global.type = "" + this.firstFinger.gestureName + "," + this.secondFinger.gestureName;
          this.targetElement.trigger("two:doubletap", this.informations);
          break;
        case "fixed,tap":
        case "tap,fixed":
        case "fixed,doubletap":
        case "doubletap,fixed":
          this.informations.global.type = "" + this.firstFinger.gestureName + "," + this.secondFinger.gestureName;
          break;
        case "fixed,drag":
        case "drag,fixed":
          this.informations.global.distance = distanceBetweenTwoPoints(this.firstFinger.params.x, this.firstFinger.params.y, this.secondFinger.params.x, this.secondFinger.params.y);
          if (this.firstFinger.gestureName === "fixed") {
            this.informations.global.type = "fixed," + this.secondFinger.params.dragDirection;
          } else {
            this.informations.global.type = "" + this.firstFinger.params.dragDirection + ",fixed";
          }
          break;
        case "doubletap,doubletap":
          this.informations.global.type = "doubletap,doubletap";
          break;
        case "fixed,fixed":
          this.informations.global.type = "fixed,fixed";
          break;
        case "fixedend,fixedend":
          this.informations.global.type = "press,press";
          break;
        case "drag,drag":
          this.informations.global.distance = distanceBetweenTwoPoints(this.firstFinger.params.x, this.firstFinger.params.y, this.secondFinger.params.x, this.secondFinger.params.y);
          this.informations.global.scale = this.informations.global.distance / this.informations.global.initialDistance;
          a1 = (this.firstFinger.params.startY - this.firstFinger.params.y) / (this.firstFinger.params.startX - this.firstFinger.params.x);
          a2 = (this.secondFinger.params.y - this.secondFinger.params.startY) / (this.secondFinger.params.x - this.secondFinger.params.startX);
          b1 = this.firstFinger.params.y - (a1 * this.firstFinger.params.x);
          b2 = this.secondFinger.params.y - (a2 * this.secondFinger.params.x);
          if (this.informations.global.scale < 0.8) {
            this.informations.global.type = "pinch";
          } else if (this.informations.global.scale > 1.2) {
            this.informations.global.type = "spread";
          } else {
            type = "" + (getDragDirection(this.firstFinger)) + "," + (getDragDirection(this.secondFinger));
            switch (type) {
              case "right,left":
                this.informations.global.type = "rotate:cw";
                break;
              case "left,right":
                this.informations.global.type = "rotate:ccw";
                break;
              case "up,down":
                this.informations.global.type = "rotate:cw";
                break;
              case "down,up":
                this.informations.global.type = "rotate:ccw";
                break;
              default:
                this.informations.global.type = type;
            }
          }
          break;
        default:
          this.informations.global.type = gestureName;
      }
      return this.targetElement.trigger(this.informations.global.type, this.informations);
    };
    /*----------------------------------------------------------------------------------------------------------------
    	## Three Finger Gesture
    	*/
    Analyser.prototype.threeFingersGesture = function() {
      var finger, gestureName, i, type, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
      i = 0;
      gestureName = "";
      if (this.firstAnalysis) {
        this.fingers = this.fingers.sort(function(a, b) {
          return a.params.startX - b.params.startX;
        });
        this.informations = {
          first: this.fingers[0].params,
          second: this.fingers[1].params,
          third: this.fingers[2].params,
          global: {}
        };
        this.firstAnalysis = false;
      }
      gestureName = "" + this.fingers[0].gestureName + "," + this.fingers[1].gestureName + "," + this.fingers[2].gestureName;
      switch (gestureName) {
        case "tap,tap,tap":
          this.informations.global.type = "tap,tap,tap";
          this.targetElement.trigger("three:tap", this.informations);
          break;
        case "doubletap,doubletap,doubletap":
          this.informations.global.type = "doubletap,doubletap,doubletap";
          this.targetElement.trigger("three:doubletap", this.informations);
          break;
        case "fixed,fixed,fixed":
          this.informations.global.type = "fixed,fixed,fixed";
          this.targetElement.trigger("three:fixed", this.informations);
          break;
        case "fixed,fixed,tap":
        case "fixed,tap,fixed":
        case "tap,fixed,fixed":
          this.informations.global.type = "" + this.fingers[0].gestureName + "," + this.fingers[1].gestureName + "," + this.fingers[2].gestureName;
          this.targetElement.trigger("two:fixed,tap", this.informations);
          this.targetElement.trigger("tap,two:fixed", this.informations);
          break;
        case "fixed,tap,tap":
        case "tap,tap,fixed":
        case "tap,fixed,tap":
          this.informations.global.type = "" + this.fingers[0].gestureName + "," + this.fingers[1].gestureName + "," + this.fingers[2].gestureName;
          this.targetElement.trigger("two:tap,fixed", this.informations);
          this.targetElement.trigger("fixed,two:tap", this.informations);
          break;
        case "fixed,fixed,doubletap":
        case "fixed,doubletap,fixed":
        case "doubletap,fixed,fixed":
          this.informations.global.type = "" + this.fingers[0].gestureName + "," + this.fingers[1].gestureName + "," + this.fingers[2].gestureName;
          this.targetElement.trigger("two:fixed,doubletap", this.informations);
          this.targetElement.trigger("doubletap,two:fixed", this.informations);
          break;
        case "fixed,doubletap,doubletap":
        case "doubletap,doubletap,fixed":
        case "doubletap,fixed,doubletap":
          this.informations.global.type = "" + this.fingers[0].gestureName + "," + this.fingers[1].gestureName + "," + this.fingers[2].gestureName;
          this.targetElement.trigger("two:doubletap,fixed", this.informations);
          this.targetElement.trigger("fixed,two:doubletap", this.informations);
          break;
        case "fixed,fixed,drag":
        case "fixed,drag,fixed":
        case "drag,fixed,fixed":
          type = "";
          i = 0;
          _ref = this.fingers;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            finger = _ref[_i];
            if (finger.gestureName === "drag") {
              type += finger.params.dragDirection;
            } else {
              type += finger.gestureName;
            }
            i++;
            if (i < this.fingers.length) {
              type += ",";
            }
          }
          this.informations.global.type = type;
          this.targetElement.trigger("two:fixed,drag", this.informations);
          this.targetElement.trigger("drag,two:fixed", this.informations);
          break;
        case "fixed,drag,drag":
        case "drag,fixed,drag":
        case "drag,drag,fixed":
          type = "";
          i = 0;
          _ref2 = this.fingers;
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            finger = _ref2[_j];
            if (finger.gestureName === "drag") {
              type += finger.params.dragDirection;
            } else {
              type += finger.gestureName;
            }
            i++;
            if (i < this.fingers.length) {
              type += ",";
            }
          }
          this.informations.global.type = type;
          this.targetElement.trigger("two:drag,fixed", this.informations);
          this.targetElement.trigger("fixed,two:drag", this.informations);
          break;
        case "drag,drag,drag":
          type = "";
          i = 0;
          _ref3 = this.fingers;
          for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
            finger = _ref3[_k];
            i++;
            type += finger.params.dragDirection;
            if (i < this.fingers.length) {
              type += ",";
            }
          }
          this.informations.global.type = type;
          this.targetElement.trigger("three:drag", this.informations);
      }
      return this.targetElement.trigger(this.informations.global.type, this.informations);
    };
    return Analyser;
  })();
  window.onload = function() {
    return $("blue").bind('all', function(a, event) {
      return $('debug').innerHTML = event.global.type;
    });
  };
}).call(this);
