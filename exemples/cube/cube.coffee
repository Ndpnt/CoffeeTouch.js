window.onload = ->
	$ = (element) ->
		document.getElementById element
	xAngle = 0
	yAngle = 0
	$('body').bind "left", (params) ->
		yAngle -= params.first.y * 90 / window.screen.height;
		$('cube').style.webkitTransform = "rotateY(-" + yAngle + "deg)"
	
	$('body').bind "right", (params) ->
		yAngle += params.first.y * 90 / window.screen.height;
		$('cube').style.webkitTransform = "rotateY(" + yAngle + "deg)"
	
	$('body').bind "up", (params) ->
		xAngle += params.first.x * 90 / window.screen.width;
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg)"
		
	$('body').bind "down", (params) ->
		xAngle -= params.first.x * 90 / window.screen.width;
		$('cube').style.webkitTransform = "rotateX(-" + xAngle + "deg)"

	$('body').bind "all", (a, params) ->
		$('debug').innerHTML = params.global.type