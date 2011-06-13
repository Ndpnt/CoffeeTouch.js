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
				@informations.global.type = @fingers[0].params.dragDirection
			
		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger


	###----------------------------------------------------------------------------------------------------------------
	## Two Finger Gesture
	###
	twoFingersGesture: ->
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName}"
		toTrigger = []
		@generateGrouppedFingerName()
		@informations.global.distance = distanceBetweenTwoPoints @fingers[0].params.x, @fingers[0].params.y, @fingers[1].params.x, @fingers[1].params.y
		switch gestureName
		
			when "tap,tap", "doubletap,doubletap", "fixed,fixed"
				toTrigger.push "two:#{@fingers[0].gestureName}"
				
			when "fixedend,fixedend"
				toTrigger.push "press,press"
				toTrigger.push "two:press"

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

		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger

	###----------------------------------------------------------------------------------------------------------------
	## Three Finger Gesture
	###
	threeFingersGesture: ->
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
		toTrigger = []
		@generateGrouppedFingerName()
		switch gestureName
			when "tap,tap,tap", "doubletap,doubletap,doubletap", "fixed,fixed,fixed"
				toTrigger.push "three:#{@fingers[0].gestureName}"

			when "fixedend,fixedend,fixedend"
				toTrigger.push "press,press,press"
				toTrigger.push "three:press"

			when "fixed,fixed,tap", "fixed,tap,fixed", "tap,fixed,fixed"
				toTrigger.push "two:fixed,tap"
				toTrigger.push "tap,two:fixed"

			when "fixed,tap,tap", "tap,tap,fixed", "tap,fixed,tap"
				toTrigger.push "two:tap,fixed"
				toTrigger.push "fixed,two:tap"

			when "fixed,fixed,doubletap", "fixed,doubletap,fixed", "doubletap,fixed,fixed"
				toTrigger.push "two:fixed,doubletap"
				toTrigger.push "doubletap,two:fixed"

			when "fixed,doubletap,doubletap", "doubletap,doubletap,fixed", "doubletap,fixed,doubletap"
				toTrigger.push "two:doubletap,fixed"
				toTrigger.push "fixed,two:doubletap"

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
				if fingers[0].params.dragDirection.contains("flick") or fingers[1].params.dragDirection.contains("flick") or fingers[2].params.dragDirection.contains("flick")
					@stopAnalyze = true
					switch dragIndex
						when 0 
							toTrigger.push "flick,fixed,fixed"
							toTrigger.push "two:fixed,flick"
						when 1 then toTrigger.push "fixed,flick,fixed"
						when 2 then toTrigger.push "fixed,fixed,flick"
				switch dragIndex
					when 0 then toTrigger.push "drag,fixed,fixed"
					when 1 then toTrigger.push "fixed,drag,fixed"
					when 2 then toTrigger.push "fixed,fixed,drag"
				toTrigger.push "two:fixed,drag"
				toTrigger.push "drag,two:fixed"
				toTrigger.push "two:fixed,#{fingers[dragIndex].params.dragDirection}"
				toTrigger.push "#{fingers[dragIndex].params.dragDirection},two:fixed"

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
				toTrigger.push @getDragDirection()
				@triggerPinchOrSpread()
				toTrigger.push "drag,drag,drag"
				toTrigger.push "three:drag"
				if @fingers[0].params.dragDirection == @fingers[1].params.dragDirection == @fingers[2].params.dragDirection
					toTrigger.push "three:#{@fingers[0].params.dragDirection}"

		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger

	###----------------------------------------------------------------------------------------------------------------
	## Four Finger Gesture
	###
	fourFingersGesture: ->
		@generateGrouppedFingerName()
		toTrigger = []
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName},#{@fingers[3].gestureName}"
		switch gestureName
			when "tap,tap,tap,tap", "doubletap,doubletap,doubletap,doubletap", "fixed,fixed,fixed,fixed"
				toTrigger.push "four:#{@fingers[0].gestureName}"

			when "fixedend,fixedend,fixedend,fixedend"
				toTrigger.push "press,press,press,press"
				toTrigger.push "four:press"
			
			when "drag,drag,drag,drag"
				toTrigger.push @getDragDirection()
				@triggerPinchOrSpread()
				toTrigger.push "drag,drag,drag,drag"
				toTrigger.push "four:drag"
				if @fingers[0].params.dragDirection == @fingers[1].params.dragDirection == @fingers[2].params.dragDirection == @fingers[3].params.dragDirection
					toTrigger.push "three:#{@fingers[0].params.dragDirection}"
		
		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger
	###----------------------------------------------------------------------------------------------------------------
	## Five Finger Gesture
	###
	fiveFingersGesture: ->
		@generateGrouppedFingerName()
		toTrigger = []
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName},#{@fingers[3].gestureName},#{@fingers[4].gestureName}"
		switch gestureName
			when "tap,tap,tap,tap,tap", "doubletap,doubletap,doubletap,doubletap,doubletap", "fixed,fixed,fixed,fixed,fixed"
				toTrigger.push "five:{@fingers[0].gestureName}"

			when "fixedend,fixedend,fixedend,fixedend,fixedend"
				toTrigger.push "press,press,press,press,press"
				toTrigger.push "five:press"
				
			when "drag,drag,drag,drag,drag,drag"
				toTrigger.push @getDragDirection()
				@triggerPinchOrSpread()
				toTrigger.push "drag,drag,drag,drag,drag"
				toTrigger.push "five:drag"

				if @fingers[0].params.dragDirection == @fingers[1].params.dragDirection == @fingers[2].params.dragDirection == @fingers[3].params.dragDirection == @fingers[4].params.dragDirection
					toTrigger.push "three:#{@fingers[0].params.dragDirection}"

		@targetElement.trigger gestureName, @informations
		@targetElement.trigger eventName, @informations	for eventName in toTrigger


	init: ->
		## Sort fingers. Left to Right and Top to Bottom
		@fingers = @fingers.sort (a,b) ->
			if Math.abs(a.params.startX - b.params.startX) < 5
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
	
	triggerRotation: -> 
		###
		if !@initialRotation?
			@initialRotation = Math.atan2(@fingers[1].params.y - @fingers[0].params.y, @fingers[1].params.x - @fingers[0].params.x)
		@informations.global.rotation = @informations.global.rotation + Math.atan2(@fingers[1].params.y - @fingers[0].params.y, @fingers[1].params.x - @fingers[0].params.x) - @initialRotation
		###
		if !@lastRotation?
			@lastRotation = @informations.global.rotation
		if @informations.global.rotation > @lastRotation
			@targetElement.trigger "rotation:cw", @informations
		else
			@targetElement.trigger "rotation:ccw", @informations
		@targetElement.trigger "rotation", @informations

		@lastRotation = @informations.global.rotation

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

	getDragDirection: ->
		type = ""
		i = 0
		for finger in @fingers
			i++
			type += finger.params.dragDirection
			type += "," if i < @fingers.length
		return type

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
				when "tap" then gestures.tap++
				when "doubletap" then gestures.doubletap++
				when "fixed" then gestures.fixed++
				when "fixedend" then gestures.fixedend++
				when "dragend" then gestures.dragend++
				when "drag"
					gestures.drag++
					switch finger.params.dragDirection
						when "up" then gestures.dragDirection.up++
						when "down" then gestures.dragDirection.down++
						when "left" then gestures.dragDirection.left++
						when "right" then gestures.dragDirection.right++
		for gesture of gestures
			if gestures[gesture] > 0
				if gesture == "dragend"
					gestureName.push "#{digit_name(gestures[gesture])}:flick"
				gestureName.push "#{digit_name(gestures[gesture])}:#{gesture}"
				gestureNameDrag.push "#{digit_name(gestures[gesture])}:#{gesture}" if gesture != "drag"
			if gesture == "dragDirection"
				for gestureDirection of gestures[gesture]
					if gestures[gesture][gestureDirection] > 0
						gestureNameDrag.push "#{digit_name(gestures[gesture][gestureDirection])}:#{gestureDirection}"
#		gestureNameDrag = gestureNameDrag.slice(0, gestureNameDrag.length - 1); ## Removing last coma
#		gestureName = gestureName.slice(0, gestureName.length - 1); ## Removing last coma

		return gestureNameDrag
	
	getCentroid: ->
		sumX = sumY = 0
		for finger in @fingers
			sumX += finger.params.startX
			sumY += finger.params.startY
		centroid =
			x: sumX / @fingers.length
			y: sumY / @fingers.length
		
	
	## Calculate the scale using centroid
	calculateScale: ->
		if !@informations.global.initialAverageDistanceToCentroid?
			## Initial calculation
			centroid = @getCentroid()
			sumAverageDistance = 0
			
			for finger in @fingers
				sumAverageDistance += distanceBetweenTwoPoints finger.params.startX, finger.params.startY, centroid.x, centroid.y
			@informations.global.initialAverageDistanceToCentroid = sumAverageDistance / @fingers.length ##/
		centroid = @getCentroid()
		sumAverageDistance = 0
		for finger in @fingers
			sumAverageDistance += distanceBetweenTwoPoints finger.params.x, finger.params.y, centroid.x, centroid.y
		averageDistance = sumAverageDistance / @fingers.length
		@informations.global.centroid = centroid
		scale = averageDistance / @informations.global.initialAverageDistanceToCentroid ##/
	
	
	# Returns a copy of an array with the element at a specific position
	# removed from it.
	arrayExcept: (arr, idx) ->
		res = arr[0..]
		res.splice idx, 1
		res
 
	# The actual function which returns the permutations of an array-like
	# object (or a proper array).
	permute: (arr) ->
		arr = Array::slice.call arr, 0
		return [[]] if arr.length == 0
		permutations = (for value,idx in arr
  			[value].concat perm for perm in @permute @arrayExcept arr, idx)
		# Flatten the array before returning it.
		[].concat permutations...
	
window.onload = ->
	$("blue").bind "flick", (event) ->
		$('debug').innerHTML = event.first.speed + "<br />" + $('debug').innerHTML
