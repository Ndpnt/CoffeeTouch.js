(function() {
  var $;
  Object.prototype.bind = function(ev, callback) {
    var calls, list;
    calls = this._callbacks || (this._callbacks = {});
    list = this._callbacks[ev] || (this._callbacks[ev] = []);
    list.push(callback);
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
  window.onload = function() {
    var t;
    t = new Date();
    $('blue').bind("doubletap", function() {
      return alert("I've been double taped");
    });
    $('blue').addEventListener('click', function(event) {
      var _t;
      _t = new Date();
      if ((_t.getTime() - t.getTime()) < 500) {
        this.trigger("doubletap");
      }
      return t = _t;
      /*
      		panX = panY = 0
      		f1 = event.touches[0]
      		alert event.touches.length		
      		*/
    });
    return $('red').addEventListener('touchstart', function(event) {
      return alert(toto);
    });
  };
}).call(this);
