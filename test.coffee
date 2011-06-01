Object::bind = (ev, callback) ->
	calls = @._callbacks or @._callbacks = {}
	list = @._callbacks[ev] or @._callbacks[ev] = []
	list.push callback
	return this

Object::unbind = (ev, callback) ->
	if !ev
		@._callbacks = {}
	else if calls = @._callbacks
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

window.onload = ->
	t = new Date()
	$('blue').bind "doubletap", ->
		alert "I've been double taped"

	$('blue').addEventListener 'click', (event) ->
		_t = new Date()
		if (_t.getTime() - t.getTime()) < 500
			this.trigger "doubletap"
		t = _t
		###
		panX = panY = 0
		f1 = event.touches[0]
		alert event.touches.length		
		###

	$('red').addEventListener 'touchstart', (event) ->
		alert toto