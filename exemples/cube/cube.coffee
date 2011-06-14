window.onload = ->
	$ = (element) ->
		document.getElementById element
	xAngle = 0
	yAngle = 0
	zAngle = 0;

	$('body').bind "flick:up", (params) ->
		xAngle += 360
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
	
	$('body').bind "flick:down", (params) ->
		xAngle -= 360
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
	
	$('body').bind "flick:left", (params) ->
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

	$('body').bind "flick:right", (params) ->
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
	
	$('body').bind "right", (params) ->
		yAngle += params.first.x * 9 / window.innerWidth
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"

	$('body').bind "left", (params) ->
		yAngle -= params.first.x * 9 / window.innerWidth
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
