###
	tap
	doubletap
	drag
	dragend

###

class StateMachine
	constructor:-> 
		@currentState = new NoTouch(this)
		@analyser = new Analyser
	apply: (eventName, eventObj) -> @currentState.apply(eventName, eventObj)
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

	apply: (eventName, @eventObj) ->
		this[eventName](@eventObj)	

	touchstart: -> #throw "undefined"
	touchmove: -> #throw "undefined"
	touchend: -> #throw "undefined"

	xthrow: (name) ->
		@param.nbFingers = @eventObj.touches.length
		$("debug").innerHTML = "throw " + name + " param: " + dump(@param) + "\n" + $("debug").innerHTML #Futur trigger
		@machine.analyser.add(name, @param)



class NoTouch extends GenericState
	description: -> "NoTouch state"
	touchstart: (event) ->
		@machine.setState(new FirstTouch @machine)
		


class FirstTouch extends GenericState
	description: -> "FirstTouch state"
	init: ->
		@param.initX = event.touches[0].clientX
		@param.initY = event.touches[0].clientY
	touchend: ->
		@xthrow "@tap"
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
		@param.currentX = event.touches[0].clientX
		@param.currentY = event.touches[0].clientY
		@xthrow "@drag"
	touchend: ->
		@xthrow "@dragend"
		@machine.setState(new NoTouch @machine)


`
function dump(arr,level) {
		var dumped_text = "["
		for(var item in arr) {
			var value = arr[item];
			if(typeof(value)=='function') continue;
			dumped_text += item + "=" + value + " ";
		}

	return dumped_text + "]";
}
`


class Analyser
	constructor: -> 
		@fingerArray = []
		@size = 0

	add: (name, param) ->
		@fingerArray.push(param)
		if @fingerArray.length == param.nbFingers
			@analyse()

	analyse: ->
		alert "J'analyse"
	




$ = (element) ->
	document.getElementById element

Object::bind = (eventName, callback) ->
	calls = @_callbacks or @_callbacks = {}
	list = @_callbacks[eventName] or @_callbacks[eventName] = []
	list.push callback


window.onload = ->
	machine = new StateMachine
	$("body").addEventListener "mousedown", (event) -> machine.apply("touchstart", event)
	$("body").addEventListener "mouseup", (event) -> machine.apply("touchend", event)
	$("body").addEventListener "mousemove", (event) -> machine.apply("touchmove", event)

	$("body").addEventListener "touchstart", (event) -> machine.apply("touchstart", event)
	$("body").addEventListener "touchend", (event) -> machine.apply("touchend", event)
	$("body").addEventListener "touchmove", (event) -> machine.apply("touchmove", event)




