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
	###
	direction = Math.atan2(deltaX, deltaY)
	pi = Math.PI
	if (pi / 4) > direction > (3 * (pi / 4))
		return "right"
	if (3 * (pi / 4)) > direction > - (3 * (pi / 4))
		return "up"
	if (3 * (pi / 4)) < direction < (3 * (pi / 4))
		return "left"
	if (pi / 4) > direction > - (pi / 4)
		return "down"
	return "-"
	
###
	if deltaX == deltaY == 0
		return "unknownDirection"
	if Math.abs(deltaX) > Math.abs(deltaY)
		## Horizontal
		if deltaX < 0 then "left" else "right"
	else
		if deltaY < 0 then "up" else "down"
###
	if deltaX > 0 and deltaY < 0 ## Right top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then return "right" else return "up"
	if deltaX > 0 and deltaY > 0 ## Right bottom side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then return "right" else return "down"
	if deltaX < 0 and deltaY < 0 ## Left top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then return "left" else return "up"
	if deltaX < 0 and deltaY > 0 ## Left top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then return "left" else return "down"
	return "diagonal"
###
getDragDirection = (finger) ->
	deltaX = finger.params.x - finger.positions[finger.positionCount - 1].x
	deltaY = finger.params.y - finger.positions[finger.positionCount - 1].y
	getDirection deltaX, deltaY	
