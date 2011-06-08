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
	constructor: (@identifier, @router)-> 
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
			@eventObj = @machine.currentState.eventObj
		else
			@eventObj = {}
		this.init()

	apply: (eventName, arg) ->
		Object.merge(@eventObj, arg)
		this[eventName]()	

	touchstart: -> #throw "undefined"
	touchmove: -> #throw "undefined"
	touchend: -> #throw "undefined"

	notify: (name) ->
		@machine.router.broadcast(name, @eventObj)
	



class NoTouch extends GenericState
	description: -> "NoTouch state"
	touchstart: ->
		@machine.setState(new FirstTouch @machine)
		


class FirstTouch extends GenericState
	description: -> "FirstTouch state"
	init: ->
		_machine = @machine
		@fixedtimer = setTimeout (->(_machine.setState new Fixed _machine)), 500
		@eventObj.initX = @eventObj.clientX
		@eventObj.initY = @eventObj.clientY
		
	touchend: ->
		clearTimeout @fixedtimer
		@notify "@tap"
		@machine.setState new NoTouch @machine

	touchmove: ->
		clearTimeout @fixedtimer
		@notify "@drag"
		@machine.setState new Drag @machine

		
class Fixed extends GenericState
	description: -> "Fixed state"
	init: ->
		@notify "@fixed"


class NoTouchDouble extends GenericState
	description: -> "NoTouch (wait double) state"
	init: -> 
		that = this;
		#@doubleTimer = setTimeout (-> alert('x');that.machine.setState(new NoTouch that.machine)), 400

	touchstart: ->
		alert('a');
		clearTimeout @doubleTimer
		@machine.setState(new FirstTouchDouble @machine)



class FirstTouchDouble extends GenericState
	description: -> "FirstTouch double state"
	touchend: ->
		alert('b');
		@notify "@doubletap"
		@machine.setState(new NoTouch @machine)
	


class Drag extends GenericState
	description: -> "Drag state"
	touchmove: ->
		@notify "@drag"
	touchend: ->
		@notify "@dragend"
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

Object.merge = function(destination, source) {
    for (var property in source) {
        if (source.hasOwnProperty(property)) {
            destination[property] = source[property];
        }
    }
    return destination;
};

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
		@nbmachines = 0	
		that = this
		@element.addEventListener "touchstart", (event) -> that.touchstart(event)
		@element.addEventListener "touchend", (event) -> that.touchend(event)
		@element.addEventListener "touchmove", (event) -> that.touchmove(event)	


	touchstart: (event) ->
		event.preventDefault()
		for i in event.changedTouches
			if !@machines[i.identifier]?
				iMachine = new StateMachine i.identifier, this
				iMachine.apply "touchstart", i
				@machines[i.identifier] = iMachine
				@nbmachines++
				@analyser = new Analyser @nbmachines, @element


	touchend: (event) ->
		event.preventDefault()
		for iMKey in @machines.keys()
			iMKey = parseInt(iMKey)
			exists = false			
			for iTouch in event.touches
				if iTouch.identifier == iMKey
					exists = true

			if !exists
				@machines[iMKey].apply("touchend", {})
				delete @machines[iMKey]	
				@nbmachines--
				
			
	 
	touchmove: (event) ->
		event.preventDefault()
		for i in event.changedTouches
			if !@machines[i.identifier]? 
				iMachine = new StateMachine i.identifier, this
				iMachine.apply "touchstart", i
				@machines[i.identifier] = iMachine
			@machines[i.identifier].apply("touchmove", i)		
			

	broadcast: (name, eventObj) ->
		analyser.notify name, eventObj
		$("debug").innerHTML = "Router: [" + name + "] " + dump(eventObj) + "\n" + $("debug").innerHTML
	
window.onload = ->
	new EventRouter $("body")





