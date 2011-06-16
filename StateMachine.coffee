####################### State Machine ####################### 
class StateMachine
	constructor: (@identifier, @router)-> 
		@currentState = new NoTouch(this)
		@analyser = new Analyser
	apply: (eventName, eventObj) ->
		@currentState.apply(eventName, eventObj)

	setState: (newState) -> @currentState = newState
	getState: -> @currentState
	
	

class GenericState
	init: -> # Defined par les sous classes

	constructor: (@machine) ->
		@eventObj = if @machine.currentState? then @machine.currentState.eventObj else {}
		this.init()

	apply: (eventName, arg) ->
		Object.merge(@eventObj, arg)
		this[eventName]()

	touchstart: -> #throw "undefined"
	touchmove: -> #throw "undefined"
	touchend: -> #throw "undefined"

	notify: (name) ->
		@machine.router.broadcast(name, @eventObj)	


class NoTouch extends GenericState
	touchstart: ->
		@machine.setState(new FirstTouch @machine)


class FirstTouch extends GenericState
	init: ->
		_machine = @machine
		@fixedtimer = setTimeout (->(_machine.setState new Fixed _machine)), 300

	touchend: ->
		clearTimeout @fixedtimer
		@notify "tap"
		@machine.setState new NoTouch @machine

	touchmove: ->
		clearTimeout @fixedtimer
		@notify "drag"
		@machine.setState new Drag @machine

		
class Fixed extends GenericState
	init: ->
		@notify "fixed"

	touchend: ->
		@notify "fixedend"
		@machine.setState new NoTouch @machine


class Drag extends GenericState
	init: ->
		@isTap = true
		@initialX = @eventObj.clientX
		@initialY = @eventObj.clientY	
		@delta = 15
		that = this		
		setTimeout (-> that.isTap = false), 150

	touchmove: ->
		@notify "drag"

	touchend: ->
		if @isTap and (Math.abs(@eventObj.clientX - @initialX) < @delta) && (Math.abs(@eventObj.clientY - @initialY) < @delta)
			@notify "tap"
		else
			@notify "dragend"
		@machine.setState(new NoTouch @machine)
