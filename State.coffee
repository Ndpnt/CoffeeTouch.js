class StateMachine
	constructor:-> @currentState = new NoTouch(this)
	apply: (event) -> @currentState.apply(event)
	setState: (newState) -> @currentState = newState
	getState: -> @currentState

	
	

class GenericState
	description: -> "Generic state"
	constructor: (@machine) ->
	apply: (event) ->
		this[event]()	

	touchstart: -> throw "undefined"
	touchmove: -> throw "undefined"
	touchend: -> throw "undefined"


class NoTouch extends GenericState
	description: -> "NoTouch state"
	touchstart: ->
		#throw "@doubletap"
		@machine.setState(new FirstTouch @machine)
		

class FirstTouch extends GenericState
	description: -> "FirstTouch state"
	touchend: ->
		#throw "@tap"
		@machine.setState(new NoTouch @machine)



window.onload = ->
	machine = new StateMachine
	machine.apply("touchstart")
	machine.apply("touchend")
	machine.apply("touchstart")
	alert machine.getState().description()
	machine.apply("touchend")
	alert machine.getState().description()

