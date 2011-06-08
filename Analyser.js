(function() {
  /*
  ## The bind, unbind and trigger function have been taken from Backbone Framework.
  ## The bind function has been changed
  */  var $, Analyser, FingerGesture;
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
  /*
  ## Exemple of use
  */
  /*
  
  window.onload = ->
  	$('blue').addEventListener 'touchstart', (event) ->
  		$('white').innerHTML += " START: " + event.touches[0].identifier + "<br />"
  	$('blue').addEventListener 'touchmove', (event) ->
  		$('white').innerHTML += " MOVE: " + event.touches[0].identifier + "<br />"
  	$('blue').addEventListener 'touchend', (event) ->
  		$('white').innerHTML += " END: " + event.touches[0].identifier + "<br />"
  */
  
/*
  window.onload = function() {
     return $('blue').addEventListener('touchmove', function(event) {
	  var prop, str;
      str = '';
      for (prop in event.changedTouches) {
        str += prop + " value :" + event[prop] + "<br />";
      }
      return $('white').innerHTML += str;
      });
  };
*/
  
;
  /*
  		$('white').innerHTML += "Number of fingers: " + event.touches.length
  		$('white').innerHTML += " first: " + event.touches[0].pageX
  		$('white').innerHTML += " second: " + event.touches[1].pageX
  */
  /*
  	$('blue').bind "tap", ->
  		alert "I've been taped"
  
  	$('white').bind "doubletap", ->
  		alert "I've been double taped"
  
  	$('red').bind "press", ->
  		alert "I've been pressed"
  */
  Object.swap = function(obj1, obj2) {
    var temp;
    temp = obj2;
    obj2 = obj1;
    return obj1 = obj2;
  };
  FingerGesture = (function() {
    function FingerGesture(fingerId, gestureName, eventObj) {
      var date;
      this.fingerId = fingerId;
      this.gestureName = gestureName;
      date = new Date();
      this.params = {};
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
    Analyser.prototype.oneFingerGesture = function() {
      var finger, key;
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
          return this.targetElement.trigger("drag", finger.params);
      }
    };
    Analyser.prototype.twoFingersGesture = function() {
      var firstFinger, gestureName, i, informations, key, secondFinger;
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
            second: secondFinger.params
          };
          this.targetElement.trigger("tap,tap", informations);
          return this.targetElement.trigger("two:tap", informations);
        case "doubleTap,doubleTap":
          return this.targetElement.trigger("doubleTap,doubleTap", finger.params);
        case "fixed,fixed":
          return this.targetElement.trigger("fixed,fixed", finger.params);
      }
    };
    return Analyser;
  })();
  window.onload = function() {
    $('blue').bind("tap,tap", function(params) {
      return $('white').innerHTML += "tap,tap x: " + params.x + "  y: " + params.y + " timeStart: " + params.timeStart + "  timeElasped: " + params.timeElasped + "<br/>";
    });
    $('blue').bind("tap", function(params) {
      return $('white').innerHTML += "tap x: " + params.x + "  y: " + params.y + " timeStart: " + params.timeStart + "  timeElasped: " + params.timeElasped + "<br/>";
    });
    $('blue').bind("fixed", function(params) {
      return $('white').innerHTML += "fixed x: " + params.x + "  y: " + params.y + " timeStart: " + params.timeStart + "  timeElasped: " + params.timeElasped + " <br/>";
    });
    $('blue').bind("drag", function(params) {
      return $('blue').style.width = (params.x + 30) + "px";
    });
    return $('blue').addEventListener('touchstart', function(event) {
      var analyser;
      analyser = new Analyser(event.touches.length, $('blue'));
      if (event.touches.length === 2) {
        analyser.notify(4, "tap", event.touches[0]);
        return analyser.notify(3, "tap", event.touches[1]);
      } else {
        return analyser.notify(12, "tap", event.touches[0]);
      }
    });
  };
}).call(this);
