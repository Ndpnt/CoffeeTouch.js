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
		@fingerCount = event.touches.length
		@grouper.refreshFingerCount @fingerCount, @element

		a = (z.identifier + " " for z in event.touches)
		for i in event.changedTouches			
			if !@machines[i.identifier]?
				@addGlobal(event, i)
				iMachine = new StateMachine i.identifier, this
				iMachine.apply "touchstart", i
				@machines[i.identifier] = iMachine


	touchend: (event) ->
		event.preventDefault()
		for iMKey of @machines
			exists = false			
			for iTouch in event.touches
				if iTouch.identifier == iMKey
					exists = true

			if !exists
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
			@analyser.notify(@fixedSave[i].identifier, "fixed", @fixedSave[i]) for i in Object.keys(@fixedSave)	
			

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
			for i in Object.keys(@fixedSave)
				delete @fixedSave[i] if eventObj.identifier == parseInt(i)
		@analyser.notify(eventObj.identifier, name, eventObj)
	
