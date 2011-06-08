Object.swap = (obj1, obj2) ->
	temp = obj2
	obj2 = obj1
	obj1 = obj2

## Finger Object which contains an Id, a gesture and all important parameters
## Params:
##		fingerId
##		gestureName
##		params
class FingerGesture
	constructor: (@fingerId, @gestureName, eventObj) ->
		date = new Date()
		@params = {}
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

	oneFingerGesture: ->
		for key of @fingersArray
			if @fingersArray.hasOwnProperty key
				finger = @fingersArray[key]

		switch finger.gestureName
			when "tap" then @targetElement.trigger "tap", finger.params
			when "doubleTap" then @targetElement.trigger "doubleTap", finger.params
			when "fixed" then @targetElement.trigger "fixed", finger.params
			when "drag" then @targetElement.trigger "drag", finger.params
	
	twoFingersGesture: ->
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
				@targetElement.trigger "tap,tap", informations
				@targetElement.trigger "two:tap", informations
			
			when "doubleTap,doubleTap"
				@targetElement.trigger "doubleTap,doubleTap", finger.params
				
			when "fixed,fixed"
				@targetElement.trigger "fixed,fixed", finger.params
##			when "drag,drag"
				## Et c'est là qu'on souffre
##				if 
##					@targetElement.trigger "drag", finger.params

window.onload = ->
	$('blue').bind "tap,tap", (params) ->
		$('white').innerHTML += "tap,tap x: #{params.x}  y: #{params.y} timeStart: #{params.timeStart}  timeElasped: #{params.timeElasped}<br/>"
	$('blue').bind "tap", (params) ->
		$('white').innerHTML += "tap x: #{params.x}  y: #{params.y} timeStart: #{params.timeStart}  timeElasped: #{params.timeElasped}<br/>"
	$('blue').bind "fixed", (params) ->
		$('white').innerHTML += "fixed x: #{params.x}  y: #{params.y} timeStart: #{params.timeStart}  timeElasped: #{params.timeElasped} <br/>"
	$('blue').bind "drag", (params) ->
		$('blue').style.width = (params.x + 30) + "px"
		

	$('blue').addEventListener 'touchstart',(event) ->
		analyser = new Analyser event.touches.length, $('blue')	
		if event.touches.length == 2
			analyser.notify 4, "tap", event.touches[0]
			analyser.notify 3, "tap", event.touches[1]
		else 
			analyser.notify 12, "tap", event.touches[0]
	
		
	
