###
	tap
	doubletap
	drag
	dragend

	automate 	touch[x]
	1		1
	
	1 2		1 2
	1 2 3		1 2 3
	1 3		1 2

###

####################### State Machine ####################### 
class StateMachine
	constructor: (@identifier)-> 
		@currentState = new NoTouch(this)
		@analyser = new Analyser
	apply: (eventName, eventObj) -> @currentState.apply(eventName, eventObj)
	setState: (newState) -> @currentState = newState
	getState: -> @currentState
	
	

class GenericState
	description: -> "Generic state"
	init: -> # Defined par les sous classes
	constructor: (@machine) ->
		if @machine.currentState?
			@param = @machine.currentState.param
		else
			@param = {'identifier':@machine.identifier}
		this.init()

	apply: (eventName, @eventObj) ->
		this[eventName](@eventObj)	

	touchstart: -> #throw "undefined"
	touchmove: -> #throw "undefined"
	touchend: -> #throw "undefined"

	xthrow: (name, index) ->
		@param.nbFingers = @eventObj.touches.length
		$("debug").innerHTML = "throw " + name + " param: " + dump(@param) + "\n" + $("debug").innerHTML #Futur trigger
		@machine.analyser.add(name, @param, index)



class NoTouch extends GenericState
	description: -> "NoTouch state"
	touchstart: (event) ->
		@machine.setState(new FirstTouch @machine)
		


class FirstTouch extends GenericState
	description: -> "FirstTouch state"
	init: ->
		@param.initX = event.touches[0].clientX
		@param.initY = event.touches[0].clientY
	touchend: ->

		@xthrow "@tap"
		@machine.setState(new NoTouchDouble @machine)
	touchmove: ->
		@xthrow "@drag"
		@machine.setState(new Drag @machine)
		



class NoTouchDouble extends GenericState
	description: -> "NoTouch wait double state"
	init: -> 
		that = this;
		setTimeout (-> that.machine.setState(new NoTouch that.machine)), 400

	touchstart: ->
		@machine.setState(new FirstTouchDouble @machine)



class FirstTouchDouble extends GenericState
	description: -> "FirstTouch double state"
	touchend: ->
		@xthrow "@doubletap"
		@machine.setState(new NoTouch @machine)
	


class Drag extends GenericState
	description: -> "Drag state"
	touchmove: ->
		@param.currentX = event.touches[0].clientX
		@param.currentY = event.touches[0].clientY
		@xthrow "@drag"
	touchend: ->
		@xthrow "@dragend"
		@machine.setState(new NoTouch @machine)


####################### Misc          ####################### 
`
function dump(arr,level) {
		var dumped_text = "["
		for(var item in arr) {
			var value = arr[item];
			if(typeof(value)=='function') continue;
			dumped_text += item + "=" + value + " ";
		}

	return dumped_text + "]";
}
function print_r(obj) {
  win_print_r = window.open('about:blank', 'win_print_r');
  win_print_r.document.write('<html><body>');
  r_print_r(obj, win_print_r);
  win_print_r.document.write('</body></html>');
 }

 function r_print_r(theObj, win_print_r) {
  if(theObj.constructor == Array ||
   theObj.constructor == Object){
   if (win_print_r == null)
    win_print_r = window.open('about:blank', 'win_print_r');
   }
   for(var p in theObj){
    if(theObj[p].constructor == Array||
     theObj[p].constructor == Object){
     win_print_r.document.write("<li>["+p+"] =>"+typeof(theObj)+"</li>");
     win_print_r.document.write("<ul>")
     r_print_r(theObj[p], win_print_r);
     win_print_r.document.write("</ul>")
    } else {
     win_print_r.document.write("<li>["+p+"] =>"+theObj[p]+"</li>");
    }
   }
  win_print_r.document.write("</ul>")
 }

Object.prototype.keys = function ()
{
  var keys = [];
  for(var i in this) if (this.hasOwnProperty(i))
  {
    keys.push(i);
  }
  return keys;
}

`

$ = (element) ->
	document.getElementById element

Object::bind = (eventName, callback) ->
	calls = @_callbacks or @_callbacks = {}
	list = @_callbacks[eventName] or @_callbacks[eventName] = []
	list.push callback

####################### Analyser      ####################### 
class Analyser
	constructor: -> 
		@fingerArray = []
		@size = 0

	add: (name, param, index) ->
		@fingerArray[index] = param
		if @fingerArray.length == param.nbFingers
			@analyse()

	analyse: ->
		#alert "J'analyse"
	


####################### EventRouter   ####################### 

class EventRouter
	constructor: (@element) ->
		@machines = {}	
		that = this
		@element.addEventListener "touchstart", (event) -> that.touchstart(event)
		@element.addEventListener "touchend", (event) -> that.touchend(event)
		@element.addEventListener "touchmove", (event) -> that.touchmove(event)	


	touchstart: (event) ->
		for i in event.changedTouches
			if !@machines[i.identifier]?
				iMachine = new StateMachine i.identifier
				iMachine.apply "touchstart", i
				@machines[i.identifier] = iMachine


	touchend: (event) ->
			for iMKey in @machines.keys()
				exists = false			
				for iTouch in event.changedTouches
					if iTouch.identifier == iMKey
						exists = true
				if !exists
					@machines[iMKey].apply("touchend", event)					
			
	 
	touchmove: (event) ->
		for i in event.changedTouches
			@machines[i.identifier].apply("touchmove", event)		


	
window.onload = ->
	new EventRouter $("body")





