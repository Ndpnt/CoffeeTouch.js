###
#--------------------------------------------------------------------------------- State
###

####################### State Machine #######################
class StateMachine
	constructor: (@identifier, @router)-> 
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
			@eventObj = @machine.currentState.eventObj
		else
			@eventObj = {}
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
	description: -> "NoTouch state"
	touchstart: ->
		@machine.setState(new FirstTouch @machine)
		


class FirstTouch extends GenericState
	description: -> "FirstTouch state"
	init: ->
		_machine = @machine
		@fixedtimer = setTimeout (->(_machine.setState new Fixed _machine)), 500
		@eventObj.initX = @eventObj.clientX
		@eventObj.initY = @eventObj.clientY
		
	touchend: ->
		clearTimeout @fixedtimer
		@notify "tap"
		@machine.setState new NoTouch @machine

	touchmove: ->
		clearTimeout @fixedtimer
		@notify "drag"
		@machine.setState new Drag @machine

		
class Fixed extends GenericState
	description: -> "Fixed state"
	init: ->
		@notify "fixed"



class Drag extends GenericState
	description: -> "Drag state"
	init: ->
		@isTap = true
		@initialX = @eventObj.clientX
		@initialY = @eventObj.clientY	
		@delta = 25
		that = this		
		setTimeout (->that.isTap = false), 150
	touchmove: ->
		@notify "drag"
	touchend: ->
		if @isTap && (Math.abs(@eventObj.clientX - @initialX) < @delta) && (Math.abs(@eventObj.clientY - @initialY) < @delta)
			@notify "tap"
		else
			@notify "dragend"
		@machine.setState(new NoTouch @machine)
