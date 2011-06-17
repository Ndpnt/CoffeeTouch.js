##	State Machine
## 		Analyse all possible basic gesture of a single finger
##
## Copyright (c) 2011
##		Pierre Corsini (pcorsini@polytech.unice.fr)
##		Nicolas Dupont (npg.dupont@gmail.com)
##		Nicolas Fernandez (fernande@polytech.unice.fr)
##		Nima Izadi (nim.izadi@gmail.com)	
##
## Permission is hereby granted, free of charge, to any person obtaining a 
## copy of this software and associated documentation files (the "Software"),
## to deal in the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense, 
## and/or sell copies of the Software, and to permit persons to whom the Software 
## is furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
## OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
## IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


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
