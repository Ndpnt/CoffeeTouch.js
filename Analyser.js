(function() {
  /*
  ## The bind, unbind and trigger function have been taken from Backbone Framework.
  ## The bind function has been changed
  */  var $, Analyser, FingerGesture, distanceBetweenTwoPoints, getDirection;
  Object.prototype.bind = function(eventName, callback) {
    var calls, list;
    calls = this._callbacks || (this._callbacks = {});
    list = this._callbacks[eventName] || (this._callbacks[eventName] = []);
    list.push(callback);
    /*
    	*/
    /*
    
    	that = this
    	## Initializing specific properties for this given object
    	@touchProperties = {};
    	@touchProperties.dateLastTouch = 0
    	
    	this.addEventListener 'touchstart', (event) ->
    		@touchProperties.isTouched = true
    
    		## Tap
    		## If a simple tap is done, trigger "tap"
    		this.trigger "tap"
    
    		## Double Tap
    		## If two tap are separated from 500 ms, trigger "doubletap"
    		_t = (new Date()).getTime()
    		if (_t - @touchProperties.dateLastTouch) < 1000
    			this.trigger "doubletap"
    		@touchProperties.dateLastTouch = _t
    		
    		## Press
    		setTimeout(-> 
    			if that.touchProperties.isTouched == true
    				that.trigger "press"
    		, 5000);
    
    	
    	for evtName in ['touchcancel','touchend']
    		@touchProperties.isTouched = false
    	
    	*/
    return this;
  };
  Object.prototype.unbind = function(ev, callback) {
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
  
Object.prototype.trigger =  function(ev) {
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
      switch (gestureName) {
        case "tap,tap":
          if (firstFinger.params.x > secondFinger.params.x) {
            Object.swap(firstFinger, secondFinger);
          }
          informations = {
            first: firstFinger.params,
            second: secondFinger.params,
            global: {
              distance: distanceBetweenTwoPoints(firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y)
            }
          };
          this.targetElement.trigger("tap,tap", informations);
          return this.targetElement.trigger("two:tap", informations);
        case "fixed,drag":
        case "drag,fixed":
          if (firstFinger.params.x > secondFinger.params.x) {
            Object.swap(firstFinger, secondFinger);
          }
          informations = {
            first: firstFinger.params,
            second: secondFinger.params,
            global: {
              distance: distanceBetweenTwoPoints(firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y)
            }
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
          return this.targetElement.trigger("doubleTap,doubleTap", finger.params);
        case "fixed,fixed":
          return this.targetElement.trigger("fixed,fixed", finger.params);
        case "drag,drag":
          if (firstFinger.params.x > secondFinger.params.x) {
            Object.swap(firstFinger, secondFinger);
          }
          informations = {
            first: firstFinger.params,
            second: secondFinger.params,
            global: {
              distance: distanceBetweenTwoPoints(firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y)
            }
          };
          deltaX = secondFinger.params.x - secondFinger.params.startX;
          deltaY = secondFinger.params.y - secondFinger.params.startY;
          alert("" + deltaX + " " + deltaY);
          alert(getDirection(deltaX, deltaY));
          return this.targetElement.trigger("" + (getDirection(deltaX, deltaY)) + "," + (getDirection(deltaX, deltaY)), informations);
      }
    };
    return Analyser;
  })();
  window.onload = function() {
    var analyser;
    $('blue').bind("down,down", function(params) {
      return $('blue').style.backgroundColor = "rgb(255,0,0)";
    });
    analyser = new Analyser(2, $('blue'));
    return $('blue').addEventListener('touchmove', function(event) {
      if (event.touches.length === 2) {
        analyser.notify(1, "drag", event.touches[1]);
        return analyser.notify(2, "drag", event.touches[0]);
      }
    });
  };
}).call(this);
