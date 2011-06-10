####################### EventRouter   ####################### 
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
		for i in event.changedTouches
			if !@machines[i.identifier]?
				iMachine = new StateMachine i.identifier, this
				iMachine.apply "touchstart", i
				@machines[i.identifier] = iMachine
				@fingerCount = event.touches.length


	touchend: (event) ->
		event.preventDefault()
		for iMKey in @machines.keys()
			iMKey = parseInt(iMKey)
			exists = false			
			for iTouch in event.touches
				if iTouch.identifier == iMKey
					exists = true

			if !exists
				@machines[iMKey].apply("touchend", {})
				delete @machines[iMKey]	
				
			
	 
	touchmove: (event) ->
		event.preventDefault()
		for i in event.changedTouches
			if !@machines[i.identifier]? 
				iMachine = new StateMachine i.identifier, this
				iMachine.apply "touchstart", i
				@machines[i.identifier] = iMachine
			@machines[i.identifier].apply("touchmove", i)		
			

	broadcast: (name, eventObj) ->
		@grouper.receive name, eventObj, @fingerCount, @element


class EventGrouper
	constructor: ->
		@savedTap = {}
	
	receive: (name, eventObj, fingerCount, element) ->

		if @fingerCount != fingerCount
			@fingerCount = fingerCount
			@analyser = new Analyser @fingerCount, element
		
		##
		if name == "tap"
			if @savedTap[eventObj.identifier]? && ((new Date().getTime()) - @savedTap[eventObj.identifier].time) < 400
				@send "doubleTap", eventObj
	
			else
				@savedTap[eventObj.identifier] =  {}
				@savedTap[eventObj.identifier].event = eventObj
				@savedTap[eventObj.identifier].time = new Date().getTime()
		##

		@send name, eventObj

	send: (name, eventObj) ->
		@analyser.notify(eventObj.identifier, name, eventObj)
	
