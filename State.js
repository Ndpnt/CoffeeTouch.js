(function() {
  /*
  	tap
  	doubletap
  	drag
  	dragend
  
  	automate 	touch[x]
  	1		1
  	
  	1 2		1 2
  	1 2 3		1 2 3
  	1 3		1 2
  
  */  var $, Drag, EventRouter, FirstTouch, FirstTouchDouble, GenericState, NoTouch, NoTouchDouble, StateMachine;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  StateMachine = (function() {
    function StateMachine(identifier) {
      this.identifier = identifier;
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
        this.param = this.machine.currentState.param;
      } else {
        this.param = {
          'identifier': this.machine.identifier
        };
      }
      this.init();
    }
    GenericState.prototype.apply = function(eventName, eventObj) {
      this.eventObj = eventObj;
      return this[eventName](this.eventObj);
    };
    GenericState.prototype.touchstart = function() {};
    GenericState.prototype.touchmove = function() {};
    GenericState.prototype.touchend = function() {};
    GenericState.prototype.xthrow = function(name, index) {
      this.param.nbFingers = this.eventObj.touches.length;
      $("debug").innerHTML = "throw " + name + " param: " + dump(this.param) + "\n" + $("debug").innerHTML;
      return this.machine.analyser.add(name, this.param, index);
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
    NoTouch.prototype.touchstart = function(event) {
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
      this.param.initX = event.touches[0].clientX;
      return this.param.initY = event.touches[0].clientY;
    };
    FirstTouch.prototype.touchend = function() {
      this.xthrow("@tap");
      return this.machine.setState(new NoTouchDouble(this.machine));
    };
    FirstTouch.prototype.touchmove = function() {
      this.xthrow("@drag");
      return this.machine.setState(new Drag(this.machine));
    };
    return FirstTouch;
  })();
  NoTouchDouble = (function() {
    function NoTouchDouble() {
      NoTouchDouble.__super__.constructor.apply(this, arguments);
    }
    __extends(NoTouchDouble, GenericState);
    NoTouchDouble.prototype.description = function() {
      return "NoTouch wait double state";
    };
    NoTouchDouble.prototype.init = function() {
      var that;
      that = this;
      return setTimeout((function() {
        return that.machine.setState(new NoTouch(that.machine));
      }), 400);
    };
    NoTouchDouble.prototype.touchstart = function() {
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
      this.xthrow("@doubletap");
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
      this.param.currentX = event.touches[0].clientX;
      this.param.currentY = event.touches[0].clientY;
      return this.xthrow("@drag");
    };
    Drag.prototype.touchend = function() {
      this.xthrow("@dragend");
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

;
  $ = function(element) {
    return document.getElementById(element);
  };
  Object.prototype.bind = function(eventName, callback) {
    var calls, list;
    calls = this._callbacks || (this._callbacks = {});
    list = this._callbacks[eventName] || (this._callbacks[eventName] = []);
    return list.push(callback);
  };
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
      _ref = event.changedTouches;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(!(this.machines[i.identifier] != null) ? (iMachine = new StateMachine(i.identifier), iMachine.apply("touchstart", i), this.machines[i.identifier] = iMachine) : void 0);
      }
      return _results;
    };
    EventRouter.prototype.touchend = function(event) {
      var exists, iMKey, iTouch, _i, _j, _len, _len2, _ref, _ref2, _results;
      _ref = this.machines.keys();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        iMKey = _ref[_i];
        exists = false;
        _ref2 = event.changedTouches;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          iTouch = _ref2[_j];
          if (iTouch.identifier === iMKey) {
            exists = true;
          }
        }
        _results.push(!exists ? this.machines[iMKey].apply("touchend", event) : void 0);
      }
      return _results;
    };
    EventRouter.prototype.touchmove = function(event) {
      var i, _i, _len, _ref, _results;
      _ref = event.changedTouches;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(this.machines[i.identifier].apply("touchmove", event));
      }
      return _results;
    };
    return EventRouter;
  })();
  window.onload = function() {
    return new EventRouter($("body"));
  };
}).call(this);
