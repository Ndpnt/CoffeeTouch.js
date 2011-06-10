window.onload = ->
	$ = (element) ->
		document.getElementById element
	canvas = new window.Viewer($('canvas'));
	$('canvas').bind "tap", (params) ->
		canvas.displayPoint(params.first.x, params.first.y, "FF0000")
	$('canvas').bind "tap,tap", (params) ->
		canvas.displayPoint(params.first.x, params.first.y, "#FF0000")
		canvas.displayPoint(params.second.x, params.second.y, "#FF0000")
		canvas.displayLine(params.first.x, params.first.y, params.second.x, params.second.y, "#0000AA")
	$('canvas').bind "tap,tap,tap", (params) ->
		canvas.displayPoint(params.first.x, params.first.y, "#FF0000")
		canvas.displayPoint(params.second.x, params.second.y, "#FF0000")
		canvas.displayPoint(params.third.x, params.third.y, "#FF0000")
		canvas.displayLine(params.first.x, params.first.y, params.second.x, params.second.y, "#0000AA")
		canvas.displayLine(params.second.x, params.second.y, params.third.x, params.third.y, "#0000AA")
		canvas.displayLine(params.first.x, params.first.y, params.third.x, params.third.y, "#0000AA")
	$('canvas').bind "all", (a, params) ->
		$('debug').innerHTML = params.global.type