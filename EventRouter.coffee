##	EventRouter
##
## Copyright (c) 2011
## Publication date: 06/17/2011
##		Pierre Corsini (pcorsini@polytech.unice.fr)
##		Nicolas Dupont (npg.dupont@gmail.com)
##		Nicolas Fernandez (fernande@polytech.unice.fr)
##		Nima Izadi (nim.izadi@gmail.com)
##		And supervised by Raphaël Bellec (r.bellec@structure-computation.com)
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

class EventRouter
	constructor: (@element) ->
		@grouper = new EventGrouper
		@machines = {}
		that = this
		@element.addEventListener "touchstart", (event) -> that.touchstart(event)
		@element.addEventListener "touchend", (event) -> that.touchend(event)
		@element.addEventListener "touchmove", (event) -> that.touchmove(event)	


	touchstart: (event) ->
		event.preventDefault()
		@fingerCount = event.touches.length
		@grouper.refreshFingerCount @fingerCount, @element

		for i in event.changedTouches	
			if !@machines[i.identifier]
				@addGlobal(event, i)
				iMachine = new StateMachine i.identifier, this
				iMachine.apply "touchstart", i
				@machines[i.identifier] = iMachine


	touchend: (event) ->
		event.preventDefault()
		for iMKey of @machines
			iMKey = parseInt(iMKey)
			exists = false	
			for iTouch in event.touches
				if iTouch.identifier == iMKey
					exists = true
			if !exists and @machines[iMKey]?
				@machines[iMKey].apply("touchend", @addGlobal(event, {}))
				delete @machines[iMKey]

					
		@fingerCount = event.touches.length
		@grouper.refreshFingerCount @fingerCount, @element			

	touchmove: (event) ->
		event.preventDefault()
		for i in event.changedTouches
			if !@machines[i.identifier]?
				iMachine = new StateMachine i.identifier, this
				iMachine.apply "touchstart", i
				@machines[i.identifier] = iMachine
			@addGlobal event, i
			@machines[i.identifier].apply("touchmove", i)		
			
	addGlobal: (event, target) ->
		target.global = {}
		target.global =
			scale: event.scale
			rotation: event.rotation
		


	broadcast: (name, eventObj) ->
		@grouper.receive name, eventObj, @fingerCount, @element


class EventGrouper
	constructor: ->
		@savedTap = {}
		@fixedSave = {}
		@fingerCount = 0
		
	refreshFingerCount: (newCount, element) -> #Initialize a new Analyzer, only if the number of fingers increase or is reset
		@fingerCount = -1 if newCount == 0

		if @fingerCount < newCount
			@fingerCount = newCount
			@analyser = new Analyser @fingerCount, element
			@analyser.notify(@fixedSave[i].identifier, "fixed", @fixedSave[i]) for i of @fixedSave
			

	receive: (name, eventObj, fingerCount, element) ->
		@send name, eventObj

		if name == "tap"
			if @savedTap[eventObj.identifier]? && ((new Date().getTime()) - @savedTap[eventObj.identifier].time) < 400
				@send "doubletap", eventObj
	
			else
				@savedTap[eventObj.identifier] =  {}
				@savedTap[eventObj.identifier].event = eventObj
				@savedTap[eventObj.identifier].time = new Date().getTime()
	


	send: (name, eventObj) ->
		if name == "fixed" then @fixedSave[eventObj.identifier] = eventObj
		else if name =="fixedend"
			for i of @fixedSave
				delete @fixedSave[i] if eventObj.identifier == parseInt(i)
		@analyser.notify(eventObj.identifier, name, eventObj)
	
