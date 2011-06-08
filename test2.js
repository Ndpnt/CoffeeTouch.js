(function() {
  /*
  ## The bind, unbind and trigger function have been taken from Backbone Framework.
  ## The bind function has been changed
  */  var $;
  Object.prototype.bind = function(eventName, callback) {
    var calls, evtName, list, that, _i, _len, _ref;
    calls = this._callbacks || (this._callbacks = {});
    list = this._callbacks[eventName] || (this._callbacks[eventName] = []);
    list.push(callback);
    /* 
    	## Modifications start here
    	*/
    that = this;
    this.touchProperties = {};
    this.touchProperties.dateLastTouch = 0;
    this.addEventListener('touchstart', function(event) {
      var _t;
      this.touchProperties.isTouched = true;
      this.trigger("tap");
      _t = (new Date()).getTime();
      if ((_t - this.touchProperties.dateLastTouch) < 1000) {
        this.trigger("doubletap");
      }
      this.touchProperties.dateLastTouch = _t;
      return setTimeout(function() {
        if (that.touchProperties.isTouched === true) {
          return that.trigger("press");
        }
      }, 5000);
    });
    _ref = ['touchcancel', 'touchend'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      evtName = _ref[_i];
      this.touchProperties.isTouched = false;
    }
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
  window.onload = function() {
    $('blue').addEventListener('touchstart', function(event) {
      $('white').innerHTML += "TouchStart " + event.touches[0].type + " <br />";
      return $('white').innerHTML += "TouchStart " + event.touches[1].type + " <br />";
    });
    return $('blue').addEventListener('touchmove', function(event) {
      $('white').innerHTML += "TouchMove " + event.touches[0].type + " <br />";
      return $('white').innerHTML += "TouchMove " + event.touches[1].type + " <br />";
    });
  };
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
}).call(this);
