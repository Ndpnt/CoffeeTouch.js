class StateMachine
	constructor:-> @currentState = new NoTouch(this)
	apply: (event, param) -> @currentState.apply(event, param)
	setState: (newState) -> @currentState = newState
	getState: -> @currentState
	
	

class GenericState
	description: -> "Generic state"
	init: -> # Defined par les sous classes
	constructor: (@machine) ->
		if @machine.currentState?
			@param = @machine.currentState.param
		else
			@param = {}
		this.init()
	apply: (event, param) ->
		this[event](param)	

	touchstart: -> #throw "undefined"
	touchmove: -> #throw "undefined"
	touchend: -> #throw "undefined"

	xthrow: (name, params) -> $("debug").innerHTML = "throw " + name + " params: " + @param.initX + "\n" + $("debug").innerHTML #Futur trigger



class NoTouch extends GenericState
	description: -> "NoTouch state"
	touchstart: (event) ->
		@param.initX = event.touches[0].clientX
		@param.llsdfsdf = "ok"
		@machine.setState(new FirstTouch @machine)
		


class FirstTouch extends GenericState
	description: -> "FirstTouch state"
	touchend: ->
		@xthrow "@tap", @params
		@machine.setState(new NoTouchDouble @machine)
	touchmove: ->
		@xthrow "@drag"
		@machine.setState(new Drag @machine)
		



class NoTouchDouble extends GenericState
	description: -> "NoTouch wait double state"
	init: -> 
		that = this;
		setTimeout (-> that.machine.setState(new NoTouch that.machine)), 400

	touchstart: ->
		@machine.setState(new FirstTouchDouble @machine)



class FirstTouchDouble extends GenericState
	description: -> "FirstTouch double state"
	touchend: ->
		@xthrow "@doubletap"
		@machine.setState(new NoTouch @machine)
	


class Drag extends GenericState
	description: -> "Drag state"
	touchmove: ->
		@xthrow "@drag"
	touchend: ->
		@xthrow "@dragend"
		@machine.setState(new NoTouch @machine)

xthrow = (name, params) -> $("debug").innerHTML = "throw " + name + "params: " + params + "\n" + $('debug').innerHTML #Futur trigger

$ = (element) ->
	document.getElementById element

Object::bind = (eventName, callback) ->
	calls = @_callbacks or @_callbacks = {}
	list = @_callbacks[eventName] or @_callbacks[eventName] = []
	list.push callback


window.onload = ->
	machine = new StateMachine
	$("body").addEventListener "mousedown", (event) -> machine.apply("touchstart")
	$("body").addEventListener "mouseup", (event) -> machine.apply("touchend")
	$("body").addEventListener "mousemove", (event) -> machine.apply("touchmove")

	$("body").addEventListener "touchstart", (event) -> machine.apply("touchstart", event)
	$("body").addEventListener "touchend", (event) -> machine.apply("touchend", event)
	$("body").addEventListener "touchmove", (event) -> machine.apply("touchmove", event)




