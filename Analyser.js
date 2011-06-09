(function() {
  /*
  ------------------------------------------------------------------------------------------------------------------------------ State
  */  var Analyser, Drag, EventRouter, FingerGesture, FirstTouch, FirstTouchDouble, Fixed, GenericState, NoTouch, NoTouchDouble, StateMachine, distanceBetweenTwoPoints, getDirection;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
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
    return Fixed;
  })();
  NoTouchDouble = (function() {
    function NoTouchDouble() {
      NoTouchDouble.__super__.constructor.apply(this, arguments);
    }
    __extends(NoTouchDouble, GenericState);
    NoTouchDouble.prototype.description = function() {
      return "NoTouch (wait double) state";
    };
    NoTouchDouble.prototype.init = function() {
      var that;
      return that = this;
    };
    NoTouchDouble.prototype.touchstart = function() {
      clearTimeout(this.doubleTimer);
      return this.machine.setState(new FirstTouchDouble(this.machine));
    };
    return NoTouchDouble;
  })();
  FirstTouchDouble = (function() {
    function FirstTouchDouble() {
      FirstTouchDouble.__super__.constructor.apply(this, arguments);
    }
    __extends(FirstTouchDouble, GenericState);
    FirstTouchDouble.prototype.description = function() {
      return "FirstTouch double state";
    };
    FirstTouchDouble.prototype.touchend = function() {
      this.notify("doubletap");
      return this.machine.setState(new NoTouch(this.machine));
    };
    return FirstTouchDouble;
  })();
  Drag = (function() {
    function Drag() {
      Drag.__super__.constructor.apply(this, arguments);
    }
    __extends(Drag, GenericState);
    Drag.prototype.description = function() {
      return "Drag state";
    };
    Drag.prototype.touchmove = function() {
      return this.notify("drag");
    };
    Drag.prototype.touchend = function() {
      this.notify("dragend");
      return this.machine.setState(new NoTouch(this.machine));
    };
    return Drag;
  })();
  
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
};
;
  EventRouter = (function() {
    function EventRouter(element) {
      var that;
      this.element = element;
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
      _ref = event.changedTouches;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(!(this.machines[i.identifier] != null) ? (iMachine = new StateMachine(i.identifier, this), iMachine.apply("touchstart", i), this.machines[i.identifier] = iMachine, $('debug').innerHTML += event.touches.length, this.analyser = new Analyser(event.touches.length, this.element)) : void 0);
      }
      return _results;
    };
    EventRouter.prototype.touchend = function(event) {
      var exists, iMKey, iTouch, _i, _j, _len, _len2, _ref, _ref2, _results;
      event.preventDefault();
      _ref = this.machines.keys();
      _results = [];
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
        _results.push(!exists ? (this.machines[iMKey].apply("touchend", {}), delete this.machines[iMKey]) : void 0);
      }
      return _results;
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
      return this.analyser.notify(eventObj.identifier, name, eventObj);
    };
    return EventRouter;
  })();
  /*
  ------------------------------------------------------------------------------------------------------------------------------ Analyser
  */
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
    if (deltaX > 0 && deltaY < 0) {
      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        "right";
      } else {
        "up";
      }
    }
    if (deltaX > 0 && deltaY > 0) {
      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        "right";
      } else {
        "down";
      }
    }
    if (deltaX < 0 && deltaY < 0) {
      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        "left";
      } else {
        "up";
      }
    }
    if (deltaX < 0 && deltaY > 0) {
      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        return "left";
      } else {
        return "down";
      }
    }
  };
  FingerGesture = (function() {
    function FingerGesture(fingerId, gestureName, eventObj) {
      var date;
      this.fingerId = fingerId;
      this.gestureName = gestureName;
      date = new Date();
      this.params = {};
      this.params.startX = eventObj.clientX;
      this.params.startY = eventObj.clientY;
      this.params.timeStart = date.getTime();
      this.params.timeElasped = 0;
      this.updatePosition(eventObj);
    }
    FingerGesture.prototype.update = function(eventObj) {
      var date;
      date = new Date();
      this.params.timeElasped = date.getTime() - this.params.timeStart;
      return this.updatePosition(eventObj);
    };
    FingerGesture.prototype.updatePosition = function(eventObj) {
      this.params.x = eventObj.clientX;
      return this.params.y = eventObj.clientY;
    };
    return FingerGesture;
  })();
  Analyser = (function() {
    function Analyser(totalNbFingers, targetElement) {
      this.totalNbFingers = totalNbFingers;
      this.targetElement = targetElement;
      this.fingersArray = {};
    }
    Analyser.prototype.notify = function(fingerID, gestureName, params) {
      if (this.fingersArray[fingerID] != null) {
        this.fingersArray[fingerID].update(params);
      } else {
        this.fingersArray[fingerID] = new FingerGesture(fingerID, gestureName, params);
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
      var deltaX, deltaY, finger, key;
      for (key in this.fingersArray) {
        if (this.fingersArray.hasOwnProperty(key)) {
          finger = this.fingersArray[key];
        }
      }
      switch (finger.gestureName) {
        case "tap":
          return this.targetElement.trigger("tap", finger.params);
        case "doubleTap":
          return this.targetElement.trigger("doubleTap", finger.params);
        case "fixed":
          return this.targetElement.trigger("fixed", finger.params);
        case "drag":
          deltaX = finger.params.x - finger.params.startX;
          deltaY = finger.params.y - finger.params.startY;
          return this.targetElement.trigger(getDirection(deltaX, deltaY), finger.params);
      }
    };
    /*----------------------------------------------------------------------------------------------------------------
    	## Two Finger Gesture
    	*/
    Analyser.prototype.twoFingersGesture = function() {
      var deltaX, deltaY, firstFinger, gestureName, i, informations, key, secondFinger;
      i = 0;
      gestureName = "";
      for (key in this.fingersArray) {
        if (this.fingersArray.hasOwnProperty(key)) {
          i++;
          if (i === 1) {
            firstFinger = this.fingersArray[key];
          }
          if (i === 2) {
            secondFinger = this.fingersArray[key];
          }
        }
      }
      gestureName = firstFinger.gestureName + "," + secondFinger.gestureName;
      if (firstFinger.params.x > secondFinger.params.x) {
        Object.swap(firstFinger, secondFinger);
      }
      informations = {
        first: firstFinger.params,
        second: secondFinger.params
      };
      switch (gestureName) {
        case "tap,tap":
          informations.global = {
            distance: distanceBetweenTwoPoints(firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y)
          };
          this.targetElement.trigger("tap,tap", informations);
          return this.targetElement.trigger("two:tap", informations);
        case "fixed,drag":
        case "drag,fixed":
          informations.global = {
            distance: distanceBetweenTwoPoints(firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y)
          };
          if (firstFinger.gestureName === "fixed") {
            deltaX = secondFinger.params.x - secondFinger.params.startX;
            deltaY = secondFinger.params.y - secondFinger.params.startY;
            return this.targetElement.trigger("fixed," + (getDirection(deltaX, deltaY)), informations);
          } else {
            deltaX = firstFinger.params.x - firstFinger.params.startX;
            deltaY = firstFinger.params.y - firstFinger.params.startY;
            return this.targetElement.trigger("" + (getDirection(deltaX, deltaY)) + ",fixed", informations);
          }
          break;
        case "doubleTap,doubleTap":
          return this.targetElement.trigger("doubleTap,doubleTap", informations);
        case "fixed,fixed":
          return this.targetElement.trigger("fixed,fixed", informations);
        case "drag,drag":
          informations.global = {
            distance: distanceBetweenTwoPoints(firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y)
          };
          deltaX = secondFinger.params.x - secondFinger.params.startX;
          deltaY = secondFinger.params.y - secondFinger.params.startY;
          return this.targetElement.trigger("" + (getDirection(deltaX, deltaY)) + "," + (getDirection(deltaX, deltaY)), informations);
      }
    };
    return Analyser;
  })();
  window.onload = function() {
    new EventRouter($("blue"));
    return $("blue").bind("fixed,down", function(params) {
      return alert("??");
    });
  };
}).call(this);
