class Analyser
	## Create an analyser object with total number of fingers and an array of all fingers as attribute
	constructor: (@totalNbFingers, @targetElement) ->
		@fingersArray = {} 		## Hash with fingerId: fingerGestureObject
		@fingers = [] 			## Array with all fingers
		@firstAnalysis = true 	## To know if we have to init the informations which will be returned
		@informations = {}
		@informations.global = {}
		date = new Date()
		@informations.global.timeStart = date.getTime()
	## Notify the analyser of a gesture (gesture name, fingerId and parameters of new position etc)
	notify: (fingerID, gestureName, @eventObj) ->
		@informations.global.rotation = @eventObj.global.rotation 
		@informations.global.scale = @eventObj.global.scale
		date = new Date()
		@informations.global.timeElasped = date.getTime() - @informations.global.timeStart
		
		if @fingersArray[fingerID]?
			@fingersArray[fingerID].update gestureName, @eventObj
		else
			@fingersArray[fingerID] =  new FingerGesture(fingerID, gestureName, @eventObj)
			@fingers.push @fingersArray[fingerID]

		@analyse @totalNbFingers if _.size(@fingersArray) is @totalNbFingers
	
	## Redirect to the correct analysis method depending the number of finger	
	analyse: (nbFingers) ->
		@init() if @firstAnalysis
		@gestureName = []
		@gestureName.push finger.gestureName for finger in @fingers
		@triggerDrag()
		@targetElement.trigger @gestureName, @informations
		@generateGrouppedFingerName()
		@triggerFixed()
		@triggerFlick()

		
	init: ->
		## Sort fingers. Left to Right and Top to Bottom
		@fingers = @fingers.sort (a,b) ->
			if Math.abs(a.params.startX - b.params.startX) < 15
				return a.params.startY - b.params.startY
			return a.params.startX - b.params.startX
		@informations.global.nbFingers = @fingers.length
		for i in [0..@fingers.length - 1]
			switch i
				when 0 then @informations.first = @fingers[0].params
				when 1 then @informations.second = @fingers[1].params
				when 2 then @informations.third = @fingers[2].params
				when 3 then @informations.fourth = @fingers[3].params
				when 4 then @informations.fifth = @fingers[4].params
		@firstAnalysis = false
	
	triggerDrag: -> 
		if @gestureName.contains "drag"
			@triggerDragDirections()
			if @gestureName.length > 1
				@triggerPinchOrSpread()
				@triggerRotation()

	triggerFixed: ->
		if @gestureName.contains "fixed"
			dontTrigger = false
			gestureName = []
			for finger in @fingers
				if finger.params.dragDirection == "unknown"
					dontTrigger = true
					break
				if finger.gestureName == "drag"
					gestureName.push finger.params.dragDirection
				else
					gestureName.push "fixed"
			$('debug').innerHTML = "#{@gestureName}<br />" + $('debug').innerHTML
			if !dontTrigger
				@targetElement.trigger gestureName, @informations
			
	triggerFlick: ->
		if @gestureName.contains "dragend"
			gestureName1 = []
			gestureName2 = []
			dontTrigger = false
			for finger in @fingers
				if finger.params.dragDirection == "unknown"
					dontTrigger = true
				if finger.isFlick
					gestureName1.push "flick:#{finger.params.dragDirection}"
					gestureName2.push "flick"
				else
					gestureName1.push finger.params.dragDirection
					gestureName2.push finger.params.dragDirection
			if !dontTrigger
				@targetElement.trigger gestureName1, @informations
				@targetElement.trigger gestureName2, @informations

	triggerDragDirections: ->
		gestureName = []
		for finger in @fingers
			gestureName.push finger.params.dragDirection
		if !gestureName.contains "unknown"
			@targetElement.trigger gestureName, @informations
		
	triggerRotation: -> 
		if !@lastRotation?
			@lastRotation = @informations.global.rotation
		rotationDirection = ""
		if @informations.global.rotation > @lastRotation then rotationDirection = "rotate:cw" else rotationDirection = "rotate:ccw"	
		@lastRotation = @informations.global.rotation
		@targetElement.trigger rotationDirection, @informations
		@targetElement.trigger "rotate", @informations

	triggerPinchOrSpread: ->
		# The scale is already sent in the event Object
		# @informations.global.scale = @calculateScale()
		## Spread and Pinch detection
		if @informations.global.scale < 1.1
			@targetElement.trigger "#{digit_name(@fingers.length)}:pinch", @informations
			@targetElement.trigger "pinch", @informations
		else if @informations.global.scale > 1.1
			@targetElement.trigger "#{digit_name(@fingers.length)}:spread", @informations
			@targetElement.trigger "spread", @informations

	generateGrouppedFingerName: -> 
		gestureName = [] 
		gestureNameDrag = []
		nbFingers = @fingers.length
		gestures = 
			tap: {n: 0}
			doubletap: {n: 0}
			fixed: {n: 0}
			fixedend: {n: 0}
			drag: {n: 0}
			dragend: {n: 0, fingers: []}
			dragDirection:
				up: {n: 0}
				down: {n: 0}
				left: {n: 0}
				right: {n: 0}
				drag: {n: 0}
		
		for finger in @fingers
			switch finger.gestureName
				when "tap" then gestures.tap.n++
				when "doubletap" then gestures.doubletap.n++
				when "fixed" then gestures.fixed.n++
				when "fixedend" then gestures.fixedend.n++
				when "dragend" 
					gestures.dragend.n++
					gestures.dragend.fingers.push finger
				when "drag"
					gestures.drag.n++
					switch finger.params.dragDirection
						when "up" then gestures.dragDirection.up.n++
						when "down" then gestures.dragDirection.down.n++
						when "right" then gestures.dragDirection.right.n++
						when "left" then gestures.dragDirection.left.n++
		for gesture of gestures
			if gestures[gesture].n > 0
				## For the flick, I consider that if two drag end has been done at the same time and one of them is
				## a flick, both of them where flick
				if gesture == "dragend"
					for finger in gestures[gesture].fingers
						if finger.isFlick
							gestureName.push "#{digit_name(gestures[gesture].n)}:flick" 
							gestureNameDrag.push "#{digit_name(gestures[gesture].n)}:flick:#{finger.params.dragDirection}"
							break
				## End Flick
				else
					gestureName.push "#{digit_name(gestures[gesture].n)}:#{gesture}"
			if gesture == "dragDirection"
				for gestureDirection of gestures[gesture]
					if gestures[gesture][gestureDirection].n > 0
						gestureNameDrag.push "#{digit_name(gestures[gesture][gestureDirection].n)}:#{gestureDirection}"
		@targetElement.trigger gestureName, @informations if gestureNameDrag.length > 0
		@targetElement.trigger gestureNameDrag, @informations if gestureNameDrag.length > 0
				
window.onload = ->
	$("blue").onGesture "all", (name, event) ->
		$('debug').innerHTML = "#{name}<br />" + $('debug').innerHTML
