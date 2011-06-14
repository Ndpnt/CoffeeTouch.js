window.onload = ->
	$ = (element) ->
		document.getElementById element
		
	canvas = $('canvas')
	ctx = canvas.getContext("2d")
	ctx.lineCap = "round"
	ctx.lineJoin = "round"
	firsttime = true
	$('canvas').bind "tap", (params) ->
		selectPoint(params.first.x, params.first.y)
		ctx.fillStyle = "rgba(0,0,0,1)";
		ctx.beginPath();
		ctx.arc(params.first.x, params.first.y, 3, 0, Math.PI * 2,true);
		ctx.closePath();
		ctx.fill();
		
	$('canvas').bind "tap,tap", (params) ->
		p1 = {
			x: params.first.x,
			y: params.first.y
		}
		p2 = {
			x: params.second.x,
			y: params.second.y
		}
		init(p1,p2)
	
	$('canvas').bind "drag", (params) ->
		if firsttime
			dragStart(params)
			firsttime = false
		else
			dragging(params)
		
	$('canvas').bind "doubletap", (params) ->
		add(params.first.x, params.first.y)
		
	$('canvas').bind "tap,tap,tap", (params) ->
		validate()
	
	$('canvas').bind "dragend", (params) ->
		firsttime = true
		dragEnd(params)

	$('canvas').bind "three:down", (params) ->
		clear()
	
	$('canvas').bind "all", (a, params) ->
		$('debug').innerHTML = a + "<br/>" + $('debug').innerHTML
	
	style = {}
	allPoint = []
	point = {}
	allvalidatePoint = []
	dPoint = {}
	drag = null	
	style =
		curve:
			width: 4
			color: "#333"
		cpline:
			width: 1
			color: "#C00"
		point:
			radius: 15
			radiusSelected: 35 
			width: 2
			color: "#900"
			colorSelected: "#AAA"
			fill: "rgba(200,200,200,0.5)"
			arc1: 0
			arc2: 2 * Math.PI

	init = (a,b) ->
		point1 =
			p:
				x: a.x
				y: a.y
			cp:
				x: (a.x + 50)
				y: (a.y + 50)
				selected: false
			validate: false
		point2 =
			p:
				x: b.x
				y: b.y
			cp:
				x: (b.x + 50)
				y: (b.y + 50)
				selected: false
			validate: false
		allPoint.push point1
		allPoint.push point2
		##default styles
		drawCanvas()

	dragEnd = (e) ->
		drag = null
		drawCanvas()
		
	add = (x,y) ->
		point =
			p:
				x: x
				y: y
				selected: false
			cp:
				x: (x + 50)
				y: (y + 50)
				selected: false
			validate: false
		allPoint.push(point)
		drawCanvas()
	
	j = 0
	validate = ->
		ctx.clearRect(0, 0, canvas.width, canvas.height)
		for i in [0..allPoint.length - 1]
			allPoint[i].validate = true if allPoint[i]
			if !allPoint[i].group?
				allPoint[i].group = j
		j++
		drawvalidatePoints()
		
	drawCanvas = ->
		ctx.clearRect(0, 0, canvas.width, canvas.height)
		for value of allPoint
			if allPoint[value].validate == false
				if allPoint[value].p
					ctx.lineWidth = style.cpline.width
					ctx.strokeStyle = style.cpline.color
					ctx.beginPath()
					ctx.moveTo(allPoint[value].p.x, allPoint[value].p.y)
					ctx.lineTo(allPoint[value].cp.x, allPoint[value].cp.y)
					ctx.stroke()
					ctx.closePath()
		
		for i in [0..allPoint.length - 1]
			if allPoint[i] and allPoint[i].validate == false and allPoint[i + 1]
				ctx.lineWidth = style.curve.width
				ctx.strokeStyle = style.curve.color
				ctx.beginPath()
				ctx.moveTo(allPoint[i].p.x, allPoint[i].p.y)
				ctx.bezierCurveTo(allPoint[i].cp.x, allPoint[i].cp.y, allPoint[i + 1].cp.x, allPoint[i + 1].cp.y, allPoint[i + 1].p.x, allPoint[i + 1].p.y)
				ctx.stroke()
				ctx.closePath()
			
		
		for value of allPoint
			if allPoint[value].validate == false
				if allPoint[value].p
					ctx.lineWidth = style.point.width
					ctx.strokeStyle = style.point.color
					ctx.fillStyle = style.point.fill
					ctx.beginPath()
					radius = if(allPoint[value].p.selected == true) then style.point.radiusSelected else style.point.radius
					ctx.arc(allPoint[value].p.x, allPoint[value].p.y, radius, style.point.arc1, style.point.arc2, true)
					ctx.fill()
					ctx.stroke()
					ctx.beginPath()
					radius = if(allPoint[value].cp.selected == true) then style.point.radiusSelected else style.point.radius
					ctx.arc(allPoint[value].cp.x, allPoint[value].cp.y, radius, style.point.arc1, style.point.arc2, true)
					ctx.fill()
					ctx.stroke()
					ctx.closePath()
		drawvalidatePoints()
	
	
	drawvalidatePoints = ->
		for i in [0..allPoint.length - 1]
			if allPoint[i] and allPoint[i].validate == true and allPoint[i + 1] and allPoint[i].group == allPoint[i + 1].group
				ctx.lineWidth = style.curve.width
				ctx.strokeStyle = style.curve.color
				ctx.beginPath()
				ctx.moveTo(allPoint[i].p.x, allPoint[i].p.y)
				ctx.bezierCurveTo(allPoint[i].cp.x, allPoint[i].cp.y, allPoint[i + 1].cp.x, allPoint[i + 1].cp.y, allPoint[i + 1].p.x, allPoint[i + 1].p.y)
				ctx.stroke()
				ctx.closePath()
		

	dragStart = (event) ->
		e =
			x: event.first.x
			y: event.first.y
		dx = dy = 0
		for value of allPoint
			if allPoint[value].validate == false
				if allPoint[value].p
					dx = allPoint[value].p.x - e.x
					dy = allPoint[value].p.y - e.y
					dcx = allPoint[value].cp.x - e.x
					dcy = allPoint[value].cp.y - e.y
					if ((dx * dx) + (dy * dy) < style.point.radiusSelected * style.point.radiusSelected and allPoint[value].p.selected == true)
						drag = allPoint[value].p
						dPoint = e
						return
					if ((dcx * dcx) + (dcy * dcy) < style.point.radiusSelected * style.point.radiusSelected and allPoint[value].cp.selected == true)
						drag = allPoint[value].cp
						dPoint = e
						return
	
	dragging = (event) ->
		if drag?
			e =
				x: event.first.x
				y: event.first.y
			drag.x += e.x - dPoint.x
			drag.y += e.y - dPoint.y
			dPoint = e
			drawCanvas()
	
	selectPoint = (x,y) ->
		e =
			x: x
			y: y
		dx = dy = 0
		for value of allPoint
			if allPoint[value].p
				allPoint[value].p.selected = false
				allPoint[value].cp.selected = false
			if allPoint[value].validate == false
				if allPoint[value].p
					dx = allPoint[value].p.x - e.x
					dy = allPoint[value].p.y - e.y
					dcx = allPoint[value].cp.x - e.x
					dcy = allPoint[value].cp.y - e.y
					if ((dx * dx) + (dy * dy) < style.point.radius * style.point.radius)
						allPoint[value].p.selected = true
						drag = allPoint[value].p
						dPoint = e
						drawCanvas()
						return
					if ((dcx * dcx) + (dcy * dcy) < style.point.radius * style.point.radius)
						allPoint[value].cp.selected = true
						drag = allPoint[value].cp
						dPoint = e
						drawCanvas()
						return
			
	clear = ->
		ctx.clearRect(0, 0, canvas.width, canvas.height)
		allPoint = []
