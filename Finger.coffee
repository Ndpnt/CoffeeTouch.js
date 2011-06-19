## Finger Object which contains an Id, a gesture and all important parameters about the finger
## Params:
##		fingerId
##		gestureName
##		params
##
## Copyright (c) 2011
## Publication date: 06/17/2011
##		Pierre Corsini (pcorsini@polytech.unice.fr)
##		Nicolas Dupont (npg.dupont@gmail.com)
##		Nicolas Fernandez (fernande@polytech.unice.fr)
##		Nima Izadi (nim.izadi@gmail.com)
##		And supervised by Raphaël Bellec (r.bellec@structure-computation.com)
##
## Permission is hereby granted, free of charge, to any person obtaining a 
## copy of this software and associated documentation files (the "Software"),
## to deal in the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense, 
## and/or sell copies of the Software, and to permit persons to whom the Software 
## is furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
## OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
## IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
		@params.gestureName = @gestureName
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
