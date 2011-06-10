window.onload = ->
	$ = (element) ->
		document.getElementById element
	xAngle = 0
	yAngle = 0
	$('cube').bind "left", (params) ->
		yAngle -= 90;
		$('cube').style.webkitTransform = "rotateY(-" + params.first.y + "deg)"
	
	$('cube').bind "right", (params) ->
		yAngle += 90;
		$('cube').style.webkitTransform = "rotateY(" + params.first.y + "deg)"
	
	$('cube').bind "up", (params) ->
		xAngle += 90;
		$('cube').style.webkitTransform = "rotateX(" + params.first.x + "deg)"
		
	$('cube').bind "down", (params) ->
		xAngle -= 90;
		$('cube').style.webkitTransform = "rotateX(-" + params.first.x + "deg)"

	$('cube').bind "all", (a, params) ->
		$('debug').innerHTML = params.global.type