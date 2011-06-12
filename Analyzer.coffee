class Analyser
	## Create an analyser object with total number of fingers and an array of all fingers as attribute
	constructor: (@totalNbFingers, @targetElement) ->
		@fingersArray = {} 	## Hash with fingerId: fingerGestureObject
		@fingers = [] 		## Array with all fingers
		@firstAnalysis = true
		@stopAnalyze = false;
	
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
			when "doubletap" then @informations.global.type = "doubletap"
			when "fixed" then @informations.global.type = "fixed"
			when "fixedend" then @informations.global.type = "press"
			when "drag"
				@informations.global.type = finger.params.dragDirection
				## Also trigger flick instead of flick:direction
				if finger.params.dragDirection.contains("flick")
					@stopAnalyze = true
					@targetElement.trigger("flick", @informations)
				@targetElement.trigger("drag", @informations)
			when "dragend" then @informations.global.type = "dragend"
			else 
				@informations.global.type = finger.gestureName
			
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
			if (Math.abs(@secondFinger.params.startX - @firstFinger.params.startX) < 5)
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
				
			when "doubletap,doubletap"
				@informations.global.type = "#{@firstFinger.gestureName},#{@secondFinger.gestureName}"
				@targetElement.trigger "two:doubletap", @informations
				
			when "fixed,tap", "tap,fixed", "fixed,doubletap", "doubletap,fixed"
				@informations.global.type = "#{@firstFinger.gestureName},#{@secondFinger.gestureName}"

			when "fixed,drag", "drag,fixed"
				## Detection of finger order. First one will be the first from the left
				@informations.global.distance = distanceBetweenTwoPoints @firstFinger.params.x, @firstFinger.params.y, @secondFinger.params.x, @secondFinger.params.y
				if @firstFinger.gestureName == "fixed"
					@informations.global.type = "fixed,#{@secondFinger.params.dragDirection}"
					@targetElement.trigger("fixed,flick", @informations) if @secondFinger.params.dragDirection.contains("flick")
				else
					@informations.global.type = "#{@firstFinger.params.dragDirection},fixed"
					@targetElement.trigger("flick,fixed", @informations) if @firstFinger.params.dragDirection.contains("flick")
				if @firstFinger.params.dragDirection.contains("flick") or @secondFinger.params.dragDirection.contains("flick")
					@stopAnalyze = true
			
			when "doubletap,doubletap"
				@informations.global.type = "doubletap,doubletap"
				
			when "fixed,fixed"
				@informations.global.type = "fixed,fixed"

			when "fixedend,fixedend"
				@informations.global.type = "press,press"
				
			when "drag,drag"
				@informations.global.distance = distanceBetweenTwoPoints @firstFinger.params.x, @firstFinger.params.y, @secondFinger.params.x, @secondFinger.params.y
				@informations.global.scale =  (@informations.global.distance / @informations.global.initialDistance) ##/
				@informations.global.type = "#{@firstFinger.params.dragDirection},#{@secondFinger.params.dragDirection}"
				a1 = (@firstFinger.params.startY - @firstFinger.params.y) / (@firstFinger.params.startX - @firstFinger.params.x);
				a2 = (@secondFinger.params.y - @secondFinger.params.startY) / (@secondFinger.params.x - @secondFinger.params.startX);
				
				b1 = @firstFinger.params.y - (a1 * @firstFinger.params.x);
				b2 = @secondFinger.params.y - (a2 * @secondFinger.params.x);

				if @informations.global.scale < 0.8
					@targetElement.trigger "pinch", @informations
				else if @informations.global.scale > 1.2
					@targetElement.trigger "spread", @informations
				
				switch @informations.global.type
					when "left,right", "up,down" then @targetElement.trigger "rotate:cw", @informations
					when "right,left", "down,up" then @targetElement.trigger "rotate:ccw", @informations

				## Also trigger flick instead of flick:direction
				@targetElement.trigger("flick,#{@firstFinger.params.dragDirection}", @informations) if @firstFinger.params.dragDirection.contains("flick")
				@targetElement.trigger("#{@firstFinger.params.dragDirection},flick", @informations) if @secondFinger.params.dragDirection.contains("flick")
				if @firstFinger.params.dragDirection.contains("flick") or @secondFinger.params.dragDirection.contains("flick")
					@stopAnalyze = true
				@targetElement.trigger("drag,drag", @informations)
			else
				@informations.global.type = gestureName
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

			when "doubletap,doubletap,doubletap"
				@informations.global.type = "doubletap,doubletap,doubletap"
				@targetElement.trigger "three:doubletap", @informations

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
				type = ""
				i = 0
				for finger in @fingers
					i++
					type += finger.params.dragDirection
					type += "," if i < @fingers.length
				@informations.global.type = type
				@targetElement.trigger "drag,drag,drag", @informations
				@targetElement.trigger "three:drag", @informations
				@targetElement.trigger "three:#{finger.params.dragDirection}", @informations
		@targetElement.trigger @informations.global.type, @informations

window.onload = ->
	$("blue").bind "all", (name, event) ->
		$('debug').innerHTML = name + "<br />" + $('debug').innerHTML
###
		if name.contains "flick"
			$('debug').innerHTML = event.global.type + "<br />"
			$('debug').innerHTML += name
###
