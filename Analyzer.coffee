class Analyser
	## Create an analyser object with total number of fingers and an array of all fingers as attribute
	constructor: (@totalNbFingers, @targetElement) ->
		@fingersArray = {} 	## Hash with fingerId: fingerGestureObject
		@fingers = [] 		## Array with all fingers
		@firstAnalysis = true
	
	## Notify the analyser of a gesture (gesture name, fingerId and parameters of new position etc)
	notify: (fingerID, gestureName, @eventObj) ->
		if @fingersArray[fingerID]?
			@fingersArray[fingerID].update gestureName, @eventObj
		else
			@fingersArray[fingerID] =  new FingerGesture(fingerID, gestureName, @eventObj)
			@fingers.push @fingersArray[fingerID]
		
		@analyse @totalNbFingers if _.size(@fingersArray) is @totalNbFingers
		##$("debug").innerHTML = "" + gestureName + "<br /> " + $("debug").innerHTML  if _.size(@fingersArray) is @totalNbFingers
	
	## Redirect to the correct analysis method depending the number of finger	
	analyse: (nbFingers) ->
		switch nbFingers
			when 1 then @oneFingerGesture @fingersArray
			when 2 then @twoFingersGesture @fingersArray
			when 3 then @threeFingersGesture @fingersArray
			when 4 then @fourFingersGesture @fingersArray
			when 5 then @fiveFingersGeture @fingersArray
			else throw "We do not analyse more than 5 fingers"
			
	###----------------------------------------------------------------------------------------------------------------
	## One Finger Gesture
	###
	oneFingerGesture: ->
		
		for key of @fingersArray
			if @fingersArray.hasOwnProperty key
				finger = @fingersArray[key]
		@informations = 
			first: finger.params
			global: {}
		
		switch finger.gestureName
			when "tap" then @informations.global.type = "tap"
			when "doubleTap" then @informations.global.type = "doubleTap"
			when "fixed" then @informations.global.type ="fixed"
			when "fixedEnd" then @informations.global.type ="press"
			when "drag"
				@informations.global.type = finger.params.dragDirection ## getDragDirection(finger)
			when "dragEnd" then @informations.global.type ="dragEnd"
			
		@targetElement.trigger(@informations.global.type, @informations)

	###----------------------------------------------------------------------------------------------------------------
	## Two Finger Gesture
	###
	twoFingersGesture: ->
		## Gesture Name detection
		i = 0
		gestureName = ""
		if @firstAnalysis
			for key of @fingersArray
				if @fingersArray.hasOwnProperty key
					i++
					@firstFinger = @fingersArray[key] if i == 1
					@secondFinger = @fingersArray[key] if i == 2
			## Detection of finger order. First one will be the first from the left
			if (Math.abs(@secondFinger.params.startX - @firstFinger.params.startX) < 20)
				if @firstFinger.params.startY > @secondFinger.params.startY
					Object.swap @firstFinger, @secondFinger
			else if @firstFinger.params.startX > @secondFinger.params.startX
				Object.swap @firstFinger, @secondFinger

			@informations =
				first: @firstFinger.params
				second: @secondFinger.params
				global:
					scale: 1
					initialDistance: distanceBetweenTwoPoints @firstFinger.params.startX, @firstFinger.params.startY, @secondFinger.params.startX, @secondFinger.params.startY
			@informations.global.distance = distanceBetweenTwoPoints @firstFinger.params.x, @firstFinger.params.y, @secondFinger.params.x, @secondFinger.params.y
			@firstAnalysis = false

		gestureName = @firstFinger.gestureName + "," + @secondFinger.gestureName
		switch gestureName
			when "tap,tap"
				@informations.global.type = "tap,tap"
				@targetElement.trigger "two:tap", @informations
				
			when "doubleTap,doubleTap"
				@informations.global.type = "#{@firstFinger.gestureName},#{@secondFinger.gestureName}"
				@targetElement.trigger "two:doubleTap", @informations
				
			when "fixed,tap", "tap,fixed"
				@informations.global.type = "#{@firstFinger.gestureName},#{@secondFinger.gestureName}"

			when "fixed,doubleTap", "doubleTap,fixed"
				@informations.global.type = "#{@firstFinger.gestureName},#{@secondFinger.gestureName}"

			when "fixed,drag", "drag,fixed"
				## Detection of finger order. First one will be the first from the left
				@informations.global.distance = distanceBetweenTwoPoints @firstFinger.params.x, @firstFinger.params.y, @secondFinger.params.x, @secondFinger.params.y
				if @firstFinger.gestureName == "fixed"
					@informations.global.type = "fixed,#{@secondFinger.params.dragDirection}"
					## @informations.global.type = "fixed,#{getDragDirection(@secondFinger)}"
				else 
					@informations.global.type = "#{@firstFinger.params.dragDirection},fixed"
					## @informations.global.type = "#{getDragDirection(@firstFinger.)},fixed"
			
			when "doubleTap,doubleTap"
				@informations.global.type = "doubleTap,doubleTap"
				
			when "fixed,fixed"
				@informations.global.type = "fixed,fixed"

			when "fixedEnd,fixedEnd"
				@informations.global.type = "press,press"
				
			when "drag,drag"
				@informations.global.distance = distanceBetweenTwoPoints @firstFinger.params.x, @firstFinger.params.y, @secondFinger.params.x, @secondFinger.params.y
				@informations.global.scale =  (@informations.global.distance / @informations.global.initialDistance) ##/
				
				a1 = (@firstFinger.params.startY - @firstFinger.params.y) / (@firstFinger.params.startX - @firstFinger.params.x);
				a2 = (@secondFinger.params.y - @secondFinger.params.startY) / (@secondFinger.params.x - @secondFinger.params.startX);
				
				b1 = @firstFinger.params.y - (a1 * @firstFinger.params.x);
				b2 = @secondFinger.params.y - (a2 * @secondFinger.params.x);
				##$("debug").innerHTML = " b1: " + Math.round(b1) + " b2 :" + Math.round(b2) + "<br />" + $("debug").innerHTML
##				$("debug").innerHTML = " angle1: " + Math.round(Math.atan2(@firstFinger.params.x,@firstFinger.params.y) * 100)/100 + " angle2 :" + Math.round(Math.atan2(@secondFinger.params.x, @secondFinger.params.y) * 100)/100 + "<br />" + $("debug").innerHTML

				if @informations.global.scale < 0.8
					@informations.global.type = "pinch"
				else if @informations.global.scale > 1.2
					@informations.global.type = "spread"
				else
					type = "#{getDragDirection(@firstFinger)},#{getDragDirection(@secondFinger)}"
					switch type
						when "right,left"
							@informations.global.type = "rotate:cw"
						when "left,right"
							@informations.global.type = "rotate:ccw"
						when "up,down"
							@informations.global.type = "rotate:cw"
						when "down,up"
							@informations.global.type = "rotate:ccw"
						else
							@informations.global.type = type
		@targetElement.trigger @informations.global.type, @informations

	###----------------------------------------------------------------------------------------------------------------
	## Three Finger Gesture
	###
	threeFingersGesture: ->
		## Gesture Name detection
		i = 0
		gestureName = ""
		if @firstAnalysis
			@fingers = @fingers.sort (a,b) ->
				return a.params.startX - b.params.startX
			@informations =
				first: @fingers[0].params
				second: @fingers[1].params
				third: @fingers[2].params
				global: {}
			@firstAnalysis = false
		gestureName = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
		switch gestureName
			when "tap,tap,tap"
				@informations.global.type = "tap,tap,tap"
				@targetElement.trigger "three:tap", @informations

			when "doubleTap,doubleTap,doubleTap"
				@informations.global.type = "doubleTap,doubleTap,doubleTap"
				@targetElement.trigger "three:doubleTap", @informations

			when "fixed,fixed,fixed"
				@informations.global.type = "fixed,fixed,fixed"
				@targetElement.trigger "three:fixed", @informations

			when "fixed,fixed,tap", "fixed,tap,fixed", "tap,fixed,fixed"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
				@targetElement.trigger "two:fixed,tap", @informations
				@targetElement.trigger "tap,two:fixed", @informations

			when "fixed,tap,tap", "tap,tap,fixed", "tap,fixed,tap"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
				@targetElement.trigger "two:tap,fixed", @informations
				@targetElement.trigger "fixed,two:tap", @informations

			when "fixed,fixed,doubleTap", "fixed,doubleTap,fixed", "doubleTap,fixed,fixed"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
				@targetElement.trigger "two:fixed,doubleTap", @informations
				@targetElement.trigger "doubleTap,two:fixed", @informations

			when "fixed,doubleTap,doubleTap", "doubleTap,doubleTap,fixed", "doubleTap,fixed,doubleTap"
				@informations.global.type = "#{@fingers[0].gestureName},#{@fingers[1].gestureName},#{@fingers[2].gestureName}"
				@targetElement.trigger "two:doubleTap,fixed", @informations
				@targetElement.trigger "fixed,two:doubleTap", @informations

			when "fixed,fixed,drag", "fixed,drag,fixed", "drag,fixed,fixed"
				type = ""
				i = 0
				for finger in @fingers
					if finger.gestureName == "drag"
						type += finger.params.dragDirection
					else 
						type += finger.gestureName
					i++
					type += "," if i < @fingers.length
				@informations.global.type = type
				@targetElement.trigger "two:fixed,drag", @informations
				@targetElement.trigger "drag,two:fixed", @informations

			when "fixed,drag,drag", "drag,fixed,drag", "drag,drag,fixed"
				type = ""
				i = 0
				for finger in @fingers
					if finger.gestureName == "drag"
						type += finger.params.dragDirection
					else 
						type += finger.gestureName
					i++
					type += "," if i < @fingers.length
				@informations.global.type = type
				@targetElement.trigger "two:drag,fixed", @informations
				@targetElement.trigger "fixed,two:drag", @informations
			when "drag,drag,drag"
				type = ""
				i = 0
				for finger in @fingers
					i++
					type += finger.params.dragDirection
					type += "," if i < @fingers.length
				@informations.global.type = type
				@targetElement.trigger "three:drag", @informations

		@targetElement.trigger @informations.global.type, @informations
