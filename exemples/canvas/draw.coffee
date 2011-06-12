window.onload = ->
	$ = (element) ->
		document.getElementById element
		
	canvas = $('canvas')
	ctx = canvas.getContext("2d")
	ctx.lineCap = "round"
	ctx.lineJoin = "round"
	firsttime = true
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
			DragStart(params)
			firsttime = false
		else
			Dragging(params)
		
	$('canvas').bind "doubleTap", (params) ->
		Add(params.first.x, params.first.y)
		$('debug').innerHTML = params.global.type + "<br/>" + $('debug').innerHTML
	$('canvas').bind "tap,tap,tap", (params) ->
		Validate()
	
	$('canvas').bind "dragend", (params) ->
		firsttime = true
		DragEnd(params)
	
	$('canvas').bind "all", (a, params) ->
		$('debug').innerHTML = a + "<br/>" + $('debug').innerHTML
	
	style = {}
	allPoint = []
	point = {}
	allValidatePoint = []
	style =
		curve:
			width: 4
			color: "#333"
		cpline:
			width: 1
			color: "#C00"
		point:
			radius: 35 
			width: 2
			color: "#900"
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
			validate: false
			
		point2 =
			p:
				x: b.x
				y: b.y
			cp:
				x: (b.x + 50)
				y: (b.y + 50)
			validate: false
		
		allPoint.push point1
		allPoint.push point2
		##default styles
		DrawCanvas()
		
	drag = null
	`
    function DrawCanvas() {
		ctx.clearRect(0, 0, canvas.width, canvas.height)
		
		for (var value in allPoint) {
			if (allPoint[value].validate === false) {
				if(allPoint[value].p) {
					ctx.lineWidth = style.cpline.width;
					ctx.strokeStyle = style.cpline.color;
					ctx.beginPath();
					ctx.moveTo(allPoint[value].p.x, allPoint[value].p.y);
					ctx.lineTo(allPoint[value].cp.x, allPoint[value].cp.y);
					ctx.stroke();
					ctx.closePath();
				}
			}
		}
		
		var i = 0
		for (i = 0; i < allPoint.length - 1; i += 1){
			if (allPoint[i].validate === false) {
				ctx.lineWidth = style.curve.width;
				ctx.strokeStyle = style.curve.color;
				ctx.beginPath();
				ctx.moveTo(allPoint[i].p.x, allPoint[i].p.y);
				ctx.bezierCurveTo(allPoint[i].cp.x, allPoint[i].cp.y, allPoint[i + 1].cp.x, allPoint[i + 1].cp.y, allPoint[i + 1].p.x, allPoint[i + 1].p.y);
				ctx.stroke();
				ctx.closePath();
			}
		}
			
		
		for (var value in allPoint) {
			if (allPoint[value].validate === false) {
				if(allPoint[value].p) {
					ctx.lineWidth = style.point.width;
					ctx.strokeStyle = style.point.color;
					ctx.fillStyle = style.point.fill;
					ctx.beginPath();
					ctx.arc(allPoint[value].p.x, allPoint[value].p.y, style.point.radius, style.point.arc1, style.point.arc2, true);
					ctx.fill();
					ctx.stroke();
					ctx.beginPath();
					ctx.arc(allPoint[value].cp.x, allPoint[value].cp.y, style.point.radius, style.point.arc1, style.point.arc2, true);
					ctx.fill();
					ctx.stroke();
					ctx.closePath();
				}
			}
		}
		DrawValidatePoints();
	}
	
	
	function DrawValidatePoints() {
		var i = 0
		for (i = 0; i < allPoint.length - 1; i += 1) {
			if (allPoint[i].validate === true && allPoint[i + 1].validate === true) {
				ctx.lineWidth = style.curve.width;
				ctx.strokeStyle = style.curve.color;
				ctx.beginPath();
				ctx.moveTo(allPoint[i].p.x, allPoint[i].p.y);
				ctx.bezierCurveTo(allPoint[i].cp.x, allPoint[i].cp.y, allPoint[i + 1].cp.x, allPoint[i + 1].cp.y, allPoint[i + 1].p.x, allPoint[i + 1].p.y);
				ctx.stroke();
				ctx.closePath();
			}
		}
	}
	
	var dPoint;
	function DragStart(event) {
		e = {
			x: event.first.x,
			y: event.first.y
		}
		var dx, dy;
		for (var value in allPoint) {
			if (allPoint[value].validate === false) {
				if(allPoint[value].p) {
					dx = allPoint[value].p.x - e.x;
					dy = allPoint[value].p.y - e.y;
					dcx = allPoint[value].cp.x - e.x;
					dcy = allPoint[value].cp.y - e.y;
					if ((dx * dx) + (dy * dy) < style.point.radius * style.point.radius) {
						drag = allPoint[value].p;
						dPoint = e;
						return;
					}
					if ((dcx * dcx) + (dcy * dcy) < style.point.radius * style.point.radius) {
						drag = allPoint[value].cp;
						dPoint = e;
						return;
					}
				}
			}
		}
	}
	
	
	// dragging
	function Dragging(event) {
		if (drag) {
			e = {
				x: event.first.x,
				y: event.first.y
			}
			drag.x += e.x - dPoint.x;
			drag.y += e.y - dPoint.y;
			dPoint = e;
			DrawCanvas();
		}
	}
	`
	DragEnd = (e) ->
		drag = null
		DrawCanvas()
			
	Add = (x,y) ->
		point =
			p:
				x: x
				y: y
			cp:
				x: (x + 50)
				y: (y + 50)
			validate: false
		allPoint.push(point)
		DrawCanvas()
	
	Validate = ->
		ctx.clearRect(0, 0, canvas.width, canvas.height)
		for i in [0.._.size(allPoint) - 1]
			allPoint[i].validate = true
		DrawValidatePoints()

