window.onload = ->
	$ = (element) ->
		document.getElementById element
	xAngle = 0
	yAngle = 0
	zAngle = 0;

	$('body').onGesture "flick:up", (params) ->
		xAngle += 360
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
	
	$('body').onGesture "flick:down", (params) ->
		xAngle -= 360
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
	
	$('body').onGesture "flick:left", (params) ->
		if (xAngle % 360) == 0
			yAngle -= 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (xAngle % 360) == -90 or (xAngle % 360) == 90
			zAngle -= 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (xAngle % 360) == -180 or (xAngle % 360) == 180
			yAngle += 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (xAngle % 360) == -270 or (xAngle % 360) == 270
			zAngle += 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"

	$('body').onGesture "flick:right", (params) ->
		if (xAngle % 360) == 0
			yAngle += 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (xAngle % 360) == -90 or (xAngle % 360) == 90
			zAngle += 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (xAngle % 360) == -180 or (xAngle % 360) == 180
			yAngle -= 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (xAngle % 360) == -270 or (xAngle % 360) == 270
			zAngle -= 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateZ(" + zAngle + "deg)"
	
	$('body').onGesture "right", (params) ->
		yAngle += params.first.x * 9 / window.innerWidth
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"

	$('body').onGesture "left", (params) ->
		yAngle -= params.first.x * 9 / window.innerWidth
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"