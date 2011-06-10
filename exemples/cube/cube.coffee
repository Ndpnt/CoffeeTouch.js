window.onload = ->
	$ = (element) ->
		document.getElementById element
	xAngle = 0
	yAngle = 0

	$('body').bind "flick:down", (params) ->
		##yAngle = params.first.y * 90 / window.screen.height
		xAngle -= 90
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg)"
	
	$('body').bind "flick:up", (params) ->
		##yAngle = params.first.y * 90 / window.screen.height
		xAngle += 90
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg)"
	
	$('body').bind "flick:left", (params) ->
		##xAngle = params.first.x * 90 / window.screen.width
		yAngle -= 90
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg)"
		
	$('body').bind "flick:right", (params) ->
		##xAngle = params.first.x * 90 / window.screen.width
		yAngle += 90
		$('cube').style.webkitTransform = "rotateX(" + xAngle + "deg) rotateY(" + yAngle + "deg)"

	###
$('body').bind "all", (a, params) ->
		$('debug').innerHTML = params.global.type
###