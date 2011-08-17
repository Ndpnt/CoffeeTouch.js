window.onload = ->
	$ = (element) ->
		document.getElementById element
	xAngle = 0
	yAngle = 0
	zAngle = 0

	$('body').onGesture "flick:up", (params) ->
		xAngle += 90
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"

	$('body').onGesture "flick:down", (params) ->
		xAngle -= 90
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
	
	$('body').onGesture "flick:left", (params) ->
		yAngle -= 90
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
		

	$('body').onGesture "flick:right", (params) ->
		yAngle += 90
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
	

	$('body').onGesture "rotate", (params) ->
		zAngle = params.rotation
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg) rotateZ(" + zAngle + "deg)"
	
