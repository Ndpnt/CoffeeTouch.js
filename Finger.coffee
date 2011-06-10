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
		@params.panX = 0
		@params.panY = 0
		@updatePosition(eventObj)

	update: (@gestureName, eventObj) ->
		date = new Date()
		@params.timeElasped = date.getTime() - @params.timeStart
		@params.dragDirection = getDragDirection(this) if @gestureName == "drag"
		@updatePosition(eventObj)

	updatePosition: (eventObj) ->
		@params.x = eventObj.clientX
		@params.y = eventObj.clientY
		@params.panX = @params.startX - @params.x
		@params.panY = @params.startY - @params.y

