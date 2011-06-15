###
 The unbind and trigger function have been taken from Backbone Framework. 
 The onGesture function is inspired by the bind functon of Backbone Framework. 
###

Element::onGesture = (eventName, callback) ->
	if !this.router?
		this.router = new EventRouter this
	calls = @_callbacks or @_callbacks = {}
	list = @_callbacks[eventName] or @_callbacks[eventName] = []
	list.push callback
	return this

Element::unbindGesture = (ev, callback) ->
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

Element::trigger = (ev) ->
	if !(calls = @._callbacks) then return this
	if list = calls[ev]
		for i in list
			i.apply(this, Array.prototype.slice.call(arguments, 1));

	if list = calls['all']
		for i in list
			i.apply(this, arguments)
	return this

$ = (element) ->
	document.getElementById element

String::contains = (it) ->
	this.indexOf(it) != -1;

Array::contains = (element) ->
	for el in this
		if (el == element) then return true
	return false

Object.merge = (destination, source) ->
	for property of source
		destination[property] = source[property] if source.hasOwnProperty property
	return destination
