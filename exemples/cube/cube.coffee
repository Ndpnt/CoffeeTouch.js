window.onload = ->
	$ = (element) ->
		document.getElementById element
	xAngle = 0
	yAngle = 0
	$('body').bind "left", (params) ->
		yAngle -= 90;
		$('cube').style.webkitTransform = "rotateY(-" + params.first.y + "deg)"
	
	$('body').bind "right", (params) ->
		yAngle += 90;
		$('cube').style.webkitTransform = "rotateY(" + params.first.y + "deg)"
	
	$('body').bind "up", (params) ->
		xAngle += 90;
		$('cube').style.webkitTransform = "rotateX(" + params.first.x + "deg)"
		
	$('body').bind "down", (params) ->
		xAngle -= 90;
		$('cube').style.webkitTransform = "rotateX(-" + params.first.x + "deg)"

	$('body').bind "all", (a, params) ->
		$('debug').innerHTML = params.global.type