
	getCentroid: ->
		sumX = sumY = 0
		for finger in @fingers
			sumX += finger.params.startX
			sumY += finger.params.startY
		centroid =
			x: sumX / @fingers.length #/
			y: sumY / @fingers.length #/
		
	
	## Calculate the scale using centroid
	calculateScale: ->
		if !@informations.global.initialAverageDistanceToCentroid?
			## Initial calculation
			centroid = @getCentroid()
			sumAverageDistance = 0
			
			for finger in @fingers
				sumAverageDistance += distanceBetweenTwoPoints finger.params.startX, finger.params.startY, centroid.x, centroid.y
			@informations.global.initialAverageDistanceToCentroid = sumAverageDistance / @fingers.length ##/
		centroid = @getCentroid()
		sumAverageDistance = 0
		for finger in @fingers
			sumAverageDistance += distanceBetweenTwoPoints finger.params.x, finger.params.y, centroid.x, centroid.y
		averageDistance = sumAverageDistance / @fingers.length #/
		@informations.global.centroid = centroid
		scale = averageDistance / @informations.global.initialAverageDistanceToCentroid ##/

	calculateRotation: -> 
		if !@initialRotation?
			@initialRotation = Math.atan2(@fingers[1].params.y - @fingers[0].params.y, @fingers[1].params.x - @fingers[0].params.x)
		@informations.global.rotation = @informations.global.rotation + Math.atan2(@fingers[1].params.y - @fingers[0].params.y, @fingers[1].params.x - @fingers[0].params.x) - @initialRotation