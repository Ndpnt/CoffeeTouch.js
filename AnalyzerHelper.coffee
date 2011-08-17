# Copyright (c) 2011
# Publication date: 06/17/2011
#		Pierre Corsini (pcorsini@polytech.unice.fr)
#		Nicolas Dupont (npg.dupont@gmail.com)
#		Nicolas Fernandez (fernande@polytech.unice.fr)
#		Nima Izadi (nim.izadi@gmail.com)
#		And supervised by Raphaël Bellec (r.bellec@structure-computation.com)

# Methods helper for the Analyzer
# Swap two object with each others.
Object.swap = (obj1, obj2) ->
	temp = obj2
	obj2 = obj1
	obj1 = obj2

# Compute the distance between two poits
distanceBetweenTwoPoints = (x1, y1, x2, y2) -> 
	Math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))

# Returns a diretion regarding two given delta.
# @params
#		deltaX: 	basicly: (currentX - lastX)
#		deltaY: 	basicly: (currentY - lastY)
getDirection = (deltaX, deltaY) ->
	if deltaX == deltaY == 0
		return "unknown"
	if Math.abs(deltaX) > Math.abs(deltaY)
		# Horizontal
		if deltaX < 0 then "left" else "right"
	else
		if deltaY < 0 then "up" else "down"

# Returns the direction of the given finger
getDragDirection = (finger) ->
	deltaX = finger.params.x - finger.positions[finger.positionCount - 1].x
	deltaY = finger.params.y - finger.positions[finger.positionCount - 1].y
	getDirection deltaX, deltaY	

# Returns the litteral digit of the numeral digit
digit_name = (->
	names = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten']
	(n) -> 
		names[n])()
