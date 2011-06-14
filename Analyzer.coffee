class Analyser
	## Create an analyser object with total number of fingers and an array of all fingers as attribute
	constructor: (@totalNbFingers, @targetElement) ->
		@fingersArray = {} 		## Hash with fingerId: fingerGestureObject
		@fingers = [] 			## Array with all fingers
		@firstAnalysis = true 	## To know if we have to init the informations which will be returned
		@informations = {}
		@informations.global = {}
	## Notify the analyser of a gesture (gesture name, fingerId and parameters of new position etc)
	notify: (fingerID, gestureName, @eventObj) ->
		@informations.global.rotation = @eventObj.global.rotation 
		@informations.global.scale = @eventObj.global.scale

		if @fingersArray[fingerID]?
			@fingersArray[fingerID].update gestureName, @eventObj
		else
			@fingersArray[fingerID] =  new FingerGesture(fingerID, gestureName, @eventObj)
			@fingers.push @fingersArray[fingerID]

		if _.size(@fingersArray) is @totalNbFingers
			@analyse @totalNbFingers
	
	## Redirect to the correct analysis method depending the number of finger	
	analyse: (nbFingers) ->
		@init() if @firstAnalysis
		switch nbFingers
			when 1 then @oneFingerGesture @fingersArray
			when 2 then @twoFingersGesture @fingersArray
			when 3 then @threeFingersGesture @fingersArray
			when 4 then @fourFingersGesture @fingersArray
			when 5 then @fiveFingersGesture @fingersArray
			else throw "We do not analyse more than 5 fingers"
			
	###----------------------------------------------------------------------------------------------------------------
	## One Finger Gesture
	###
	oneFingerGesture: ->
		toTrigger = []
		gestureName = @fingers[0].gestureName
		@generateGrouppedFingerName()
		switch gestureName
			when "fixedend" then @informations.global.type = "press"
			when "dragend"
				if @fingers[0].isFlick
					toTrigger.push "flick"
					toTrigger.push "flick:#{@fingers[0].params.dragDirection}"
			when "drag"
				@triggerDragDirections()
			
		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger if toTrigger.length > 0 


	###----------------------------------------------------------------------------------------------------------------
	## Two Finger Gesture
	###
	twoFingersGesture: ->
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName}"
		toTrigger = []
		@generateGrouppedFingerName()
		@informations.global.distance = distanceBetweenTwoPoints @fingers[0].params.x, @fingers[0].params.y, @fingers[1].params.x, @fingers[1].params.y
		switch gestureName
						
			when "fixedend,fixedend"
				toTrigger.push "press,press"
				
			when "fixed,drag"
				toTrigger.push "fixed,#{@fingers[1].params.dragDirection}"
			when "drag,fixed"
				toTrigger.push "#{@fingers[0].params.dragDirection},fixed"

			## Flick case
			when "dragend,dragend"
				toTrigger.push("flick,flick") if @fingers[0].isFlick and @fingers[1].isFlick
			when "dragend,drag", "drag,dragend"	
				if @fingers[0].isFlick
					toTrigger.push "flick,#{@fingers[1].params.dragDirection}"
					toTrigger.push "flick:#{@fingers[0].params.dragDirection},#{@fingers[1].params.dragDirection}"
				else if @fingers[1].isFlick
					toTrigger.push "#{@fingers[0].params.dragDirection},flick"
					toTrigger.push "#{@fingers[0].params.dragDirection},flick:#{@fingers[1].params.dragDirection}"
			## Flick end
													
			when "drag,drag"
				@triggerPinchOrSpread()
				@triggerRotation()
				@triggerDragDirections()

		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger if toTrigger.length > 0
	###----------------------------------------------------------------------------------------------------------------
	## Three Finger Gesture
	###
	threeFingersGesture: ->
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
		toTrigger = []
		@generateGrouppedFingerName()
		switch gestureName

			when "fixedend,fixedend,fixedend"
				toTrigger.push "press,press,press"

			when "fixed,fixed,drag", "fixed,drag,fixed", "drag,fixed,fixed"
				type = ""
				i = dragIndex = 0
				for finger in @fingers
					if finger.gestureName == "drag"
						type += finger.params.dragDirection
						dragIndex = i
					else 
						type += finger.gestureName
					i++
					type += "," if i < @fingers.length
				toTrigger.push type
				switch dragIndex
					when 0 then toTrigger.push "drag,fixed,fixed"
					when 1 then toTrigger.push "fixed,drag,fixed"
					when 2 then toTrigger.push "fixed,fixed,drag"

			when "fixed,drag,drag", "drag,fixed,drag", "drag,drag,fixed"
				type = ""
				i = fixedIndex = 0
				for finger in @fingers
					if finger.gestureName == "drag"
						type += finger.params.dragDirection
					else 
						type += finger.gestureName
						fixedIndex = i
					i++
					type += "," if i < @fingers.length
				toTrigger.push type
				
				switch fixedIndex
					when 0 then toTrigger.push "fixed,drag,drag"
					when 1 then toTrigger.push "drag,fixed,drag"
					when 2 then toTrigger.push "drag,drag,fixed"
				toTrigger.push "two:drag,fixed"
				toTrigger.push "fixed,two:drag"
			when "drag,drag,drag"
				@triggerPinchOrSpread()
				@triggerRotation()
				@triggerDragDirections()

		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger if toTrigger.length > 0
	###----------------------------------------------------------------------------------------------------------------
	## Four Finger Gesture
	###
	fourFingersGesture: ->
		@generateGrouppedFingerName()
		toTrigger = []
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName},#{@fingers[3].gestureName}"
		switch gestureName
			when "fixedend,fixedend,fixedend,fixedend"
				toTrigger.push "press,press,press,press"
			
			when "drag,drag,drag,drag"
				@triggerPinchOrSpread()
				@triggerRotation()
				@triggerDragDirections()
				
		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger if toTrigger.length > 0
	###----------------------------------------------------------------------------------------------------------------
	## Five Finger Gesture
	###
	fiveFingersGesture: ->
		@generateGrouppedFingerName()
		toTrigger = []
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName},#{@fingers[3].gestureName},#{@fingers[4].gestureName}"
		switch gestureName
			when "fixedend,fixedend,fixedend,fixedend,fixedend"
				toTrigger.push "press,press,press,press,press"
				
			when "drag,drag,drag,drag,drag"
				@triggerPinchOrSpread()
				@triggerRotation()
				@triggerDragDirections()

		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger if toTrigger.length > 0
		
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
		
	triggerFlick: ->
		finished = true
		for finger in @fingers
			if finger.gestureName == "dragend" then finished = false
		if !finished
			gestureName1 = []
			gestureName2 = []
			for finger in @fingers
				if finger.isFlick
					gestureName1 += "flick:#{finger.params.dragDirection}"
					gestureName2 += "flick"
				else
					gestureName1 += finger.params.dragDirection
					gestureName2 += finger.params.dragDirection
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
		if @informations.global.rotation > @lastRotation then rotationDirection = "rotation:cw" else rotationDirection = "rotation:ccw"	
		@lastRotation = @informations.global.rotation
		@targetElement.trigger rotationDirection, @informations
		@targetElement.trigger "rotation", @informations

	triggerPinchOrSpread: ->
		# The scale is already sent in the event Object
		# @informations.global.scale = @calculateScale()
		## Spread and Pinch detection
		if @informations.global.scale < 1
			@targetElement.trigger "#{digit_name(@fingers.length)}:pinch", @informations
			@targetElement.trigger "pinch", @informations
		else if @informations.global.scale > 1
			@targetElement.trigger "#{digit_name(@fingers.length)}:spread", @informations
			@targetElement.trigger "spread", @informations

	generateGrouppedFingerName: -> 
		gestureName = [] 
		gestureNameDrag = []
		i = 0
		nbFingers = @fingers.length
		gestures = 
			tap: {n: 0, fingers: []}
			doubletap: {n: 0, fingers: []}
			fixed: {n: 0, fingers: []}
			fixedend: {n: 0, fingers: []}
			drag: {n: 0, fingers: []}
			dragend: {n: 0, fingers: []}
			dragDirection:
				up: {n: 0, fingers: []}
				down: {n: 0, fingers: []}
				left: {n: 0, fingers: []}
				right: {n: 0, fingers: []}
				drag: {n: 0, fingers: []}
		
		for finger in @fingers
			switch finger.gestureName
				when "tap" 
					gestures.tap.n++
					gestures.tap.fingers.push finger
				when "doubletap"
					gestures.doubletap.n++
					gestures.doubletap.fingers.push finger
				when "fixed" 
					gestures.fixed.n++
					gestures.fixed.fingers.push finger
				when "fixedend"
					gestures.fixedend.n++
					gestures.fixedend.fingers.push finger
				when "dragend" 
					gestures.dragend.n++
					gestures.dragend.fingers.push finger
				when "drag"
					gestures.drag.n++
					gestures.drag.fingers.push finger
					switch finger.params.dragDirection
						when "up" 
							gestures.dragDirection.up.n++
							gestures.dragDirection.up.fingers.push finger
						when "down" 
							gestures.dragDirection.down.n++
							gestures.dragDirection.down.fingers.push finger
						when "right" 
							gestures.dragDirection.right.n++
							gestures.dragDirection.right.fingers.push finger
						when "left" 
							gestures.dragDirection.left.n++
							gestures.dragDirection.left.fingers.push finger
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
				else if gesture == "fixedend"
					gestureName.push "#{digit_name(gestures[gesture].n)}:press"
				else
					gestureName.push "#{digit_name(gestures[gesture].n)}:#{gesture}"
			if gesture == "dragDirection"
				for gestureDirection of gestures[gesture]
					if gestures[gesture][gestureDirection].n > 0
						gestureNameDrag.push "#{digit_name(gestures[gesture][gestureDirection].n)}:#{gestureDirection}"
#		$('debug').innerHTML = "--#{gestureName}<br />" + $('debug').innerHTML
		@targetElement.trigger gestureName, @informations if gestureNameDrag.length > 0
		@targetElement.trigger gestureNameDrag, @informations if gestureNameDrag.length > 0
				
window.onload = ->
	$("blue").bind "all", (name, event) ->
		$('debug').innerHTML = "#{name}<br />" + $('debug').innerHTML