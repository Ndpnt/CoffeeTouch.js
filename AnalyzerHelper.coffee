#---------------------------------------------------------------------- Helper Methods
##
## Methods helper
Object.swap = (obj1, obj2) ->
	temp = obj2
	obj2 = obj1
	obj1 = obj2

distanceBetweenTwoPoints = (x1, y1, x2, y2) -> 
	Math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))

getDirection = (deltaX, deltaY) ->
	if deltaX > 0 and deltaY < 0 ## Right top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then return "right" else return "up"
	if deltaX > 0 and deltaY > 0 ## Right bottom side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then return "right" else return "down"
	if deltaX < 0 and deltaY < 0 ## Left top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then return "left" else return "up"
	if deltaX < 0 and deltaY > 0 ## Left top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then return "left" else return "down"
	return "diagonal"

getDragDirection = (finger) ->
	deltaX = finger.params.x - finger.params.startX
	deltaY = finger.params.y - finger.params.startY
	getDirection deltaX, deltaY	
