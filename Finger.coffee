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
		@positions[0] = {}
		@positionCount = 0
		@params.startX = @positions[0].x = eventObj.clientX
		@params.startY = @positions[0].y = eventObj.clientY
		@params.timeStart = date.getTime()
		@params.timeElasped = 0
		@params.panX = 0
		@params.panY = 0
		@updatePosition(eventObj)

	update: (@gestureName, eventObj) ->
		@positionCount++
		@positions[@positionCount] = {}
		@positions[@positionCount].x = eventObj.clientX
		@positions[@positionCount].y = eventObj.clientY
		date = new Date()
		@params.timeElasped = date.getTime() - @params.timeStart
		@params.dragDirection = getDragDirection(this) if @gestureName == "drag"
		@updatePosition eventObj


	updatePosition: (eventObj) ->
		@params.x = eventObj.clientX
		@params.y = eventObj.clientY
		@params.panX = @params.startX - @params.x
		@params.panY = @params.startY - @params.y
