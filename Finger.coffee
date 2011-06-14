## Finger Object which contains an Id, a gesture and all important parameters
## Params:
##		fingerId
##		gestureName
##		params
class FingerGesture
	constructor: (@fingerId, @gestureName, eventObj) ->
		date = new Date()
		@params = {}
		@positions = []
		@positions[0] = 
			x: eventObj.clientX
			y: eventObj.clientY
			time: date.getTime()
		@positionCount = 0
		@params.startX = eventObj.clientX
		@params.startY = eventObj.clientY
		@params.timeStart = date.getTime()
		@params.timeElasped = 0
		@params.panX = 0
		@params.panY = 0
		@updatePosition(eventObj)
		@params.speed = 0
		@params.dragDirection = "unknown"
		@isFlick = false

	update: (@gestureName, eventObj) ->
		@positionCount++
		date = new Date()
		@positions[@positionCount] =
			x: eventObj.clientX
			y: eventObj.clientY
			time: date.getTime()
		@params.timeElasped = date.getTime() - @params.timeStart
		@updatePosition eventObj
		if @gestureName == "drag"
			movedX = @params.x - @positions[@positionCount - 1].x
			movedY = @params.y - @positions[@positionCount - 1].y
			@params.speed = Math.sqrt(movedX * movedX  + movedY  * movedY) / (@positions[@positionCount].time - @positions[@positionCount - 1].time) #/
			@params.dragDirection = getDragDirection(this)
		if @gestureName == "dragend"
			if @params.speed > 0.5 or @params.timeElasped < 100
				@isFlick = true

	updatePosition: (eventObj) ->
		@params.x = eventObj.clientX
		@params.y = eventObj.clientY
		@params.panX = @params.x - @params.startX
		@params.panY = @params.y - @params.startY
