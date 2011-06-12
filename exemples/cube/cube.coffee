window.onload = ->
	$ = (element) ->
		document.getElementById element
	xAngle = 0
	yAngle = 0
	zAngle = 0;

	$('body').bind "flick:up", (params) ->
		if (yAngle % 360) == 0
			xAngle += 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (yAngle % 360) == -90 or (yAngle % 360) == 90
			zAngle += 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (yAngle % 360) == -180 or (yAngle % 360) == 180
			xAngle -= 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (yAngle % 360) == -270 or (yAngle % 360) == 270
			zAngle -= 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		
		##$('debug').innerHTML = "Xangle: " + xAngle + "Yangle: " + yAngle + "Zangle: " + zAngle + "<br/>" + $('debug').innerHTML
	
	$('body').bind "flick:down", (params) ->
		if (yAngle % 360) == 0
			xAngle -= 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (yAngle % 360) == -90 or (yAngle % 360) == 90
			zAngle += 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (yAngle % 360) == -180 or (yAngle % 360) == 180
			xAngle += 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (yAngle % 360) == -270 or (yAngle % 360) == 270
			zAngle += 90
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		##$('debug').innerHTML = "Xangle: " + xAngle + "Yangle: " + yAngle + "Zangle: " + zAngle + "<br/>" + $('debug').innerHTML
	
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
		##$('debug').innerHTML = "Xangle: " + xAngle + "Yangle: " + yAngle + "Zangle: " + zAngle + "<br/>" + $('debug').innerHTML

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
		##$('debug').innerHTML = "Xangle: " + xAngle + "Yangle: " + yAngle + "Zangle: " + zAngle + "<br/>" + $('debug').innerHTML
	
	$('body').bind "right", (params) ->
		if (xAngle % 360) == 0
			yAngle += params.first.panX * 90 / window.innerWidth
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (xAngle % 360) == -90 or (xAngle % 360) == 90
			zAngle += params.first.panX * 90 / window.innerWidth
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (xAngle % 360) == -180 or (xAngle % 360) == 180
			yAngle -= params.first.panX * 90 / window.innerWidth
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		if (xAngle % 360) == -270 or (xAngle % 360) == 270
			zAngle -= params.first.panX * 90 / window.innerWidth
			$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateZ(" + zAngle + "deg)"
		$('debug').innerHTML += params.first.x * 90 / window.innerWidth + " inner : " + window.innerWidth

	###
$('body').bind "all", (a, params) ->
		$('debug').innerHTML = params.global.type
###