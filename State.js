(function() {
  var $, Drag, FirstTouch, FirstTouchDouble, GenericState, NoTouch, NoTouchDouble, StateMachine, xthrow;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  StateMachine = (function() {
    function StateMachine() {
      this.currentState = new NoTouch(this);
    }
    StateMachine.prototype.apply = function(event, param) {
      return this.currentState.apply(event, param);
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
        this.param = {};
      }
      this.init();
    }
    GenericState.prototype.apply = function(event, param) {
      return this[event](param);
    };
    GenericState.prototype.touchstart = function() {};
    GenericState.prototype.touchmove = function() {};
    GenericState.prototype.touchend = function() {};
    GenericState.prototype.xthrow = function(name, params) {
      return $("debug").innerHTML = "throw " + name + " params: " + this.param.initX + "\n" + $("debug").innerHTML;
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
      this.param.initX = event.touches[0].clientX;
      this.param.llsdfsdf = "ok";
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
    FirstTouch.prototype.touchend = function() {
      this.xthrow("@tap", this.params);
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
      return this.xthrow("@drag");
    };
    Drag.prototype.touchend = function() {
      this.xthrow("@dragend");
      return this.machine.setState(new NoTouch(this.machine));
    };
    return Drag;
  })();
  xthrow = function(name, params) {
    return $("debug").innerHTML = "throw " + name + "params: " + params + "\n" + $('debug').innerHTML;
  };
  $ = function(element) {
    return document.getElementById(element);
  };
  Object.prototype.bind = function(eventName, callback) {
    var calls, list;
    calls = this._callbacks || (this._callbacks = {});
    list = this._callbacks[eventName] || (this._callbacks[eventName] = []);
    return list.push(callback);
  };
  window.onload = function() {
    var machine;
    machine = new StateMachine;
    $("body").addEventListener("mousedown", function(event) {
      return machine.apply("touchstart");
    });
    $("body").addEventListener("mouseup", function(event) {
      return machine.apply("touchend");
    });
    $("body").addEventListener("mousemove", function(event) {
      return machine.apply("touchmove");
    });
    $("body").addEventListener("touchstart", function(event) {
      return machine.apply("touchstart", event);
    });
    $("body").addEventListener("touchend", function(event) {
      return machine.apply("touchend", event);
    });
    return $("body").addEventListener("touchmove", function(event) {
      return machine.apply("touchmove", event);
    });
  };
}).call(this);
