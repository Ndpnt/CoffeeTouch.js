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
		@params.dragDirection = "none"

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
			@params.speed = Math.sqrt(movedX * movedX  + movedY  * movedY) / (@positions[@positionCount].time - @positions[@positionCount - 1].time) 
			
			if @params.speed > 1.1
				@params.dragDirection = "flick:" + getDragDirection(this)
			else
				@params.dragDirection = getDragDirection(this)
			@params.direction = Math.atan2(@params.panY, @params.panX)

	updatePosition: (eventObj) ->
		@params.x = eventObj.clientX
		@params.y = eventObj.clientY
		@params.panX = Math.abs(@params.startX - @params.x)
		@params.panY = Math.abs(@params.startY - @params.y)
