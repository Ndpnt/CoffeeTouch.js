###
## The bind, unbind and trigger function have been taken from Backbone Framework.
## The bind function has been changed
###

Object::bind = (eventName, callback) ->
	calls = @_callbacks or @_callbacks = {}
	list = @_callbacks[eventName] or @_callbacks[eventName] = []
	list.push callback
	###
	### 
	## Modifications start here
	###

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
	
	###
	return this

Object::unbind = (ev, callback) ->
	if !ev
		@_callbacks = {}
	else if calls = @_callbacks
		if !callback
			calls[ev] = []
		else
			list = calls[ev];
			if !list 
				return this
			for i in list
				if callback == list[i]
					list.splice(i, 1)
					break
	return this

`
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
`

$ = (element) ->
	document.getElementById element
