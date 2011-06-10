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
	if Math.abs(deltaX) > Math.abs(deltaY)
		## Horizontal
		if deltaX < 0 then "left" else "right"
	else
		if deltaY < 0 then "up" else "down"


getDragDirection = (finger) ->
	deltaX = finger.params.x - finger.params.startX
	deltaY = finger.params.y - finger.params.startY
	getDirection deltaX, deltaY	
