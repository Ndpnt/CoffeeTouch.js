class Analyser
	## Create an analyser object with total number of fingers and an array of all fingers as attribute
	constructor: (@totalNbFingers, @targetElement) ->
		@fingersArray = {} 	## Hash with fingerId: fingerGestureObject
		@fingers = [] 		## Array with all fingers
		@firstAnalysis = true
		@stopAnalyze = false
	
	## Notify the analyser of a gesture (gesture name, fingerId and parameters of new position etc)
	notify: (fingerID, gestureName, @eventObj) ->
#		$('debug').innerHTML = @fingersArray[fingerID]? + "<br />" + $("debug").innerHTML 
		if @fingersArray[fingerID]?
			@fingersArray[fingerID].update gestureName, @eventObj
		else
			@fingersArray[fingerID] =  new FingerGesture(fingerID, gestureName, @eventObj)
			@fingers.push @fingersArray[fingerID]

		if _.size(@fingersArray) is @totalNbFingers and !@stopAnalyze
			@analyse @totalNbFingers

		##$("debug").innerHTML = "" + gestureName + "<br /> " + $("debug").innerHTML  if _.size(@fingersArray) is @totalNbFingers
	
	## Redirect to the correct analysis method depending the number of finger	
	analyse: (nbFingers) ->
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
		@initInformations()
		gestureName = @fingers[0].gestureName
		switch gestureName
			when "tap" then @informations.global.type = "tap"
			when "doubletap" then @informations.global.type = "doubletap"
			when "fixed" then @informations.global.type = "fixed"
			when "fixedend" then @informations.global.type = "press"
			when "drag"
				@informations.global.type = @fingers[0].params.dragDirection
				## Also trigger flick instead of flick:direction
				if @fingers[0].params.dragDirection.contains("flick")
					@stopAnalyze = true
					@targetElement.trigger("flick", @informations)
				@targetElement.trigger("drag", @informations)
			when "dragend" then @informations.global.type = "dragend"
			else 
				@informations.global.type = @fingers[0].gestureName
			
		@targetElement.trigger(@informations.global.type, @informations)

	###----------------------------------------------------------------------------------------------------------------
	## Two Finger Gesture
	###
	twoFingersGesture: ->
		@initInformations()
		gestureName = @fingers[0].gestureName + "," + @fingers[1].gestureName
		switch gestureName
			when "tap,tap"
				@informations.global.type = "tap,tap"
				@targetElement.trigger "two:tap", @informations
				
			when "doubletap,doubletap"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName}"
				@targetElement.trigger "two:doubletap", @informations

			when "fixedend,fixedend"
				@informations.global.type = "press,press"
				@targetElement.trigger "two:press", @informations
				
			when "fixed,tap", "tap,fixed", "fixed,doubletap", "doubletap,fixed"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName}"

			when "fixed,drag", "drag,fixed"
				## Detection of finger order. First one will be the first from the left
				@informations.global.distance = distanceBetweenTwoPoints @fingers[0].params.x, @fingers[0].params.y, @fingers[1].params.x, @fingers[1].params.y
				if @fingers[0].gestureName == "fixed"
					@informations.global.type = "fixed,#{@fingers[1].params.dragDirection}"
					@targetElement.trigger("fixed,flick", @informations) if @fingers[1].params.dragDirection.contains("flick")
				else
					@informations.global.type = "#{@fingers[0].params.dragDirection},fixed"
					@targetElement.trigger("flick,fixed", @informations) if @fingers[0].params.dragDirection.contains("flick")
				if @fingers[0].params.dragDirection.contains("flick") or @fingers[1].params.dragDirection.contains("flick")
					@stopAnalyze = true
			
			when "doubletap,doubletap"
				@informations.global.type = "doubletap,doubletap"
				
			when "fixed,fixed"
				@informations.global.type = "fixed,fixed"

			when "fixedend,fixedend"
				@informations.global.type = "press,press"
				
			when "drag,drag"
				@informations.global.distance = distanceBetweenTwoPoints @fingers[0].params.x, @fingers[0].params.y, @fingers[1].params.x, @fingers[1].params.y
				@informations.global.type = "#{@fingers[0].params.dragDirection},#{@fingers[1].params.dragDirection}"
				@triggerPinchOrSpread()				
				switch @informations.global.type
					when "left,right", "up,down" then @targetElement.trigger "rotate:cw", @informations
					when "right,left", "down,up" then @targetElement.trigger "rotate:ccw", @informations

				## Also trigger flick instead of flick:direction
				@targetElement.trigger("flick,flick", @informations) if @fingers[0].params.dragDirection.contains("flick") and @fingers[1].params.dragDirection.contains("flick")
				@targetElement.trigger("flick,#{@fingers[0].params.dragDirection}", @informations) if @fingers[0].params.dragDirection.contains("flick") and !@fingers[1].params.dragDirection.contains("flick")
				@targetElement.trigger("#{@fingers[0].params.dragDirection},flick", @informations) if @fingers[1].params.dragDirection.contains("flick") and !@fingers[0].params.dragDirection.contains("flick")
				if @fingers[0].params.dragDirection.contains("flick") or @fingers[1].params.dragDirection.contains("flick")
					@stopAnalyze = true
				@targetElement.trigger("drag,drag", @informations)
			else
				@informations.global.type = gestureName
		@targetElement.trigger @informations.global.type, @informations

	###----------------------------------------------------------------------------------------------------------------
	## Three Finger Gesture
	###
	threeFingersGesture: ->
		@initInformations()
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
		switch gestureName
			when "tap,tap,tap"
				@informations.global.type = "tap,tap,tap"
				@targetElement.trigger "three:tap", @informations

			when "doubletap,doubletap,doubletap"
				@informations.global.type = "doubletap,doubletap,doubletap"
				@targetElement.trigger "three:doubletap", @informations

			when "fixed,fixed,fixed"
				@informations.global.type = "fixed,fixed,fixed"
				@targetElement.trigger "three:fixed", @informations

			when "fixedend,fixedend,fixedend"
				@informations.global.type = "press,press,press"
				@targetElement.trigger "three:press", @informations

			when "fixed,fixed,tap", "fixed,tap,fixed", "tap,fixed,fixed"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
				@targetElement.trigger "two:fixed,tap", @informations
				@targetElement.trigger "tap,two:fixed", @informations

			when "fixed,tap,tap", "tap,tap,fixed", "tap,fixed,tap"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
				@targetElement.trigger "two:tap,fixed", @informations
				@targetElement.trigger "fixed,two:tap", @informations

			when "fixed,fixed,doubletap", "fixed,doubletap,fixed", "doubletap,fixed,fixed"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
				@targetElement.trigger "two:fixed,doubletap", @informations
				@targetElement.trigger "doubletap,two:fixed", @informations

			when "fixed,doubletap,doubletap", "doubletap,doubletap,fixed", "doubletap,fixed,doubletap"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
				@targetElement.trigger "two:doubletap,fixed", @informations
				@targetElement.trigger "fixed,two:doubletap", @informations

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
				@informations.global.type = type
				if fingers[0].params.dragDirection.contains("flick") or fingers[1].params.dragDirection.contains("flick") or fingers[2].params.dragDirection.contains("flick")
					@stopAnalyze = true
					switch dragIndex
						when 0 then @targetElement.trigger "flick,fixed,fixed", @informations
						when 1 then @targetElement.trigger "fixed,flick,fixed", @informations
						when 2 then @targetElement.trigger "fixed,fixed,flick", @informations
				switch dragIndex
					when 0 then @targetElement.trigger "drag,fixed,fixed", @informations
					when 1 then @targetElement.trigger "fixed,drag,fixed", @informations
					when 2 then @targetElement.trigger "fixed,fixed,drag", @informations
				@targetElement.trigger "two:fixed,drag", @informations
				@targetElement.trigger "drag,two:fixed", @informations
				@targetElement.trigger "two:fixed,#{fingers[dragIndex].params.dragDirection}", @informations
				@targetElement.trigger "#{fingers[dragIndex].params.dragDirection},two:fixed", @informations

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
				@informations.global.type = type
				
				switch fixedIndex
					when 0 then @targetElement.trigger "fixed,drag,drag", @informations
					when 1 then @targetElement.trigger "drag,fixed,drag", @informations
					when 2 then @targetElement.trigger "drag,drag,fixed", @informations
				@targetElement.trigger "two:drag,fixed", @informations
				@targetElement.trigger "fixed,two:drag", @informations
			when "drag,drag,drag"
				@informations.global.type = @getDragDirection()
				@triggerPinchOrSpread()
				@targetElement.trigger "drag,drag,drag", @informations
				@targetElement.trigger "three:drag", @informations
				if @fingers[0].params.dragDirection == @fingers[1].params.dragDirection == @fingers[2].params.dragDirection
					@targetElement.trigger "three:#{@fingers[0].params.dragDirection}", @informations
		@targetElement.trigger @informations.global.type, @informations
	###----------------------------------------------------------------------------------------------------------------
	## Four Finger Gesture
	###
	fourFingersGesture: ->
		@initInformations()
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName},#{@fingers[3].gestureName}"
		switch gestureName
			when "tap,tap,tap,tap"
				@targetElement.trigger "tap,tap,tap,tap", @informations
				@targetElement.trigger "four:tap", @informations

			when "doubletap,doubletap,doubletap,doubletap"
				@targetElement.trigger "doubletap,doubletap,doubletap,doubletap", @informations
				@targetElement.trigger "four:doubletap", @informations

			when "fixed,fixed,fixed,fixed"
				@targetElement.trigger "fixed,fixed,fixed,fixed", @informations
				@targetElement.trigger "four:fixed", @informations

			when "fixedend,fixedend,fixedend,fixedend"
				@targetElement.trigger "press,press,press,press", @informations
				@targetElement.trigger "four:press", @informations
			
			when "drag,drag,drag,drag"
				@informations.global.type = @getDragDirection()
				@triggerPinchOrSpread()
				@targetElement.trigger "drag,drag,drag,drag", @informations
				@targetElement.trigger "four:drag", @informations
				if @fingers[0].params.dragDirection == @fingers[1].params.dragDirection == @fingers[2].params.dragDirection == @fingers[3].params.dragDirection
					@targetElement.trigger "three:#{@fingers[0].params.dragDirection}", @informations
		
		@targetElement.trigger @informations.global.type, @informations
	###----------------------------------------------------------------------------------------------------------------
	## Five Finger Gesture
	###
	fiveFingersGesture: ->
		@initInformations()
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName},#{@fingers[3].gestureName},#{@fingers[4].gestureName}"
		switch gestureName
			when "tap,tap,tap,tap,tap"
				@targetElement.trigger "tap,tap,tap,tap,tap", @informations
				@targetElement.trigger "five:tap", @informations

			when "doubletap,doubletap,doubletap,doubletap,doubletap"
				@targetElement.trigger "doubletap,doubletap,doubletap,doubletap", @informations
				@targetElement.trigger "five:doubletap", @informations

			when "fixed,fixed,fixed,fixed,fixed"
				@targetElement.trigger "fixed,fixed,fixed,fixed,fixed", @informations
				@targetElement.trigger "five:fixed", @informations

			when "fixedend,fixedend,fixedend,fixedend,fixedend"
				@targetElement.trigger "press,press,press,press,press", @informations
				@targetElement.trigger "five:press", @informations
				
			when "drag,drag,drag,drag,drag,drag"
				@informations.global.type = @getDragDirection()
				@triggerPinchOrSpread()
				@targetElement.trigger "drag,drag,drag,drag,drag", @informations
				@targetElement.trigger "five:drag", @informations

				if @fingers[0].params.dragDirection == @fingers[1].params.dragDirection == @fingers[2].params.dragDirection == @fingers[3].params.dragDirection == @fingers[4].params.dragDirection
					@targetElement.trigger "three:#{@fingers[0].params.dragDirection}", @informations
		@targetElement.trigger @informations.global.type, @informations

	initInformations: ->
		if @firstAnalysis
			@fingers = @fingers.sort (a,b) ->
				if Math.abs(a.params.startX - b.params.startX) < 5
					return a.params.startY - b.params.startY
				return a.params.startX - b.params.startX
			@informations =
				global: 
					nbFingers: @fingers.length
			for i in [0..@fingers.length - 1]
				switch i
					when 0 then @informations.first = @fingers[0].params
					when 1 then @informations.second = @fingers[1].params
					when 2 then @informations.third = @fingers[2].params
					when 3 then @informations.fourth = @fingers[3].params
					when 4 then @informations.fifth = @fingers[4].params
			@firstAnalysis = false

	triggerPinchOrSpread: ->
		@informations.global.scale = @calculateScale()
		## Spread and Pinch detection
		if @informations.global.scale < 0.9
			@targetElement.trigger "#{digit_name(@fingers.length)}:pinch", @informations
			@targetElement.trigger "pinch", @informations
		else if @informations.global.scale > 1.1
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

	calculateScale: ->
		if !@informations.global.initialAverageDistanceToCentroid?
			## Initial calculation
			sumX = sumY = 0
			for finger in @fingers
				sumX += finger.params.startX
				sumY += finger.params.startY
			centroidX = sumX / @fingers.length
			centroidY = sumY / @fingers.length
			sumAverageDistance = 0
			for finger in @fingers
				sumAverageDistance += distanceBetweenTwoPoints finger.params.startX, finger.params.startY, centroidX, centroidY
			@informations.global.initialAverageDistanceToCentroid = sumAverageDistance / @fingers.length ##/
		sumX = sumY = 0
		for finger in @fingers
			sumX += finger.params.x
			sumY += finger.params.y
		centroidX = sumX / @fingers.length
		centroidY = sumY / @fingers.length
		sumAverageDistance = 0
		for finger in @fingers
			sumAverageDistance += distanceBetweenTwoPoints finger.params.x, finger.params.y, centroidX, centroidY
		averageDistance = sumAverageDistance / @fingers.length
		@informations.global.centroid =
			x: centroidX
			y: centroidY
		scale = averageDistance / @informations.global.initialAverageDistanceToCentroid ##/

	
window.onload = ->
	$("blue").bind "spread", (event) ->
		$('debug').innerHTML = event.global.scale + "<br />" + $('debug').innerHTML
###
		if name.contains "flick"
			$('debug').innerHTML = event.global.type + "<br />"
			$('debug').innerHTML += name
###
