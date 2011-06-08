## Methods helper
Object.swap = (obj1, obj2) ->
	temp = obj2
	obj2 = obj1
	obj1 = obj2

distanceBetweenTwoPoints = (x1, y1, x2, y2) -> 
	Math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))

getDirection = (deltaX, deltaY) ->
	if deltaX > 0 and deltaY < 0 ## Right top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then "right" else "up"
	if deltaX > 0 and deltaY > 0 ## Right bottom side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then "right" else "down"
	if deltaX < 0 and deltaY < 0 ## Left top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then "left" else "up"
	if deltaX < 0 and deltaY > 0 ## Left top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then "left" else "down"

## Finger Object which contains an Id, a gesture and all important parameters
## Params:
##		fingerId
##		gestureName
##		params
class FingerGesture
	constructor: (@fingerId, @gestureName, eventObj) ->
		date = new Date()
		@params = {}
		@params.startX = eventObj.clientX
		@params.startY = eventObj.clientY
		@params.timeStart = date.getTime()
		@params.timeElasped = 0
		@updatePosition(eventObj)

	update: (eventObj) ->
		date = new Date()
		@params.timeElasped = date.getTime() - @params.timeStart
		@updatePosition(eventObj)

	updatePosition: (eventObj) ->
		@params.x = eventObj.clientX
		@params.y = eventObj.clientY

class Analyser
	## Create an analyser object with total number of fingers and an array of all fingers as attribute
	constructor: (@totalNbFingers, @targetElement) ->
		@fingersArray = {}
	
	## Notify the analyser of a gesture (gesture name, fingerId and parameters of new position etc)
	notify: (fingerID, gestureName, params) ->
		if @fingersArray[fingerID]?
			@fingersArray[fingerID].update params
		else
			@fingersArray[fingerID] =  new FingerGesture(fingerID, gestureName, params)
		
		@analyse @totalNbFingers if _.size(@fingersArray) is @totalNbFingers
		
	
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

		switch finger.gestureName
			when "tap" then @targetElement.trigger "tap", finger.params
			when "doubleTap" then @targetElement.trigger "doubleTap", finger.params
			when "fixed" then @targetElement.trigger "fixed", finger.params
			when "drag"
				deltaX = finger.params.x - finger.params.startX
				deltaY = finger.params.y - finger.params.startY
				@targetElement.trigger getDirection(deltaX, deltaY), finger.params 
				
	###----------------------------------------------------------------------------------------------------------------
	## Two Finger Gesture
	###
	twoFingersGesture: ->
		## Gesture Name detection
		i = 0
		gestureName = ""
		for key of @fingersArray
			if @fingersArray.hasOwnProperty key
				i++
				firstFinger = @fingersArray[key] if i == 1
				secondFinger = @fingersArray[key] if i == 2
		gestureName = firstFinger.gestureName + "," + secondFinger.gestureName
		switch gestureName
			when "tap,tap"
				## Detection of finger order. First one will be the first from the left
				if firstFinger.params.x > secondFinger.params.x
					Object.swap firstFinger, secondFinger
				informations =
					first: firstFinger.params
					second: secondFinger.params
					global:
						distance: distanceBetweenTwoPoints firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y

				@targetElement.trigger "tap,tap", informations
				@targetElement.trigger "two:tap", informations
				
			when "fixed,drag", "drag,fixed"
				## Detection of finger order. First one will be the first from the left
				if firstFinger.params.x > secondFinger.params.x
					Object.swap firstFinger, secondFinger
				informations =
					first: firstFinger.params
					second: secondFinger.params
					global:
						distance: distanceBetweenTwoPoints firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y

				if firstFinger.gestureName == "fixed"
					deltaX = secondFinger.params.x - secondFinger.params.startX
					deltaY = secondFinger.params.y - secondFinger.params.startY
					@targetElement.trigger "fixed,#{getDirection(deltaX, deltaY)}", informations
				else 
					deltaX = firstFinger.params.x - firstFinger.params.startX
					deltaY = firstFinger.params.y - firstFinger.params.startY
					@targetElement.trigger "#{getDirection(deltaX, deltaY)},fixed", informations
			
			when "doubleTap,doubleTap"
				@targetElement.trigger "doubleTap,doubleTap", finger.params
				
			when "fixed,fixed"
				@targetElement.trigger "fixed,fixed", finger.params
				
			when "drag,drag"
				## Et c'est là qu'on souffre
				if firstFinger.params.x > secondFinger.params.x
					Object.swap firstFinger, secondFinger
				informations =
					first: firstFinger.params
					second: secondFinger.params
					global:
						distance: distanceBetweenTwoPoints firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y
				deltaX = secondFinger.params.x - secondFinger.params.startX
				deltaY = secondFinger.params.y - secondFinger.params.startY
				alert "#{deltaX} #{deltaY}"
				alert getDirection(deltaX, deltaY)
				@targetElement.trigger "#{getDirection(deltaX, deltaY)},#{getDirection(deltaX, deltaY)}", informations
				
window.onload = ->	
	$('blue').bind "down,down", (params) ->
		$('blue').style.backgroundColor = "rgb(255,0,0)"
		
	
	analyser = new Analyser 2, $('blue')
	$('blue').addEventListener 'touchmove',(event) ->
		if event.touches.length == 2
			analyser.notify 1, "drag", event.touches[1]
			analyser.notify 2, "drag", event.touches[0]
		
	
