###
------------------------------------------------------------------------------------------------------------------------------ State
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
		@notify "tap"
		@machine.setState new NoTouch @machine

	touchmove: ->
		clearTimeout @fixedtimer
		@notify "drag"
		@machine.setState new Drag @machine

		
class Fixed extends GenericState
	description: -> "Fixed state"
	init: ->
		@notify "fixed"


class NoTouchDouble extends GenericState
	description: -> "NoTouch (wait double) state"
	init: -> 
		that = this;
		#@doubleTimer = setTimeout (-> alert('x');that.machine.setState(new NoTouch that.machine)), 400

	touchstart: ->
		clearTimeout @doubleTimer
		@machine.setState(new FirstTouchDouble @machine)



class FirstTouchDouble extends GenericState
	description: -> "FirstTouch double state"
	touchend: ->
		@notify "doubletap"
		@machine.setState(new NoTouch @machine)
	


class Drag extends GenericState
	description: -> "Drag state"
	touchmove: ->
		@notify "drag"
	touchend: ->
		@notify "dragend"
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

####################### EventRouter   ####################### 

class EventRouter
	constructor: (@element) ->
		@machines = {}
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
				$('debug').innerHTML += event.touches.length
				@analyser = new Analyser event.touches.length, @element


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
				
			
	 
	touchmove: (event) ->
		event.preventDefault()
		for i in event.changedTouches
			if !@machines[i.identifier]? 
				iMachine = new StateMachine i.identifier, this
				iMachine.apply "touchstart", i
				@machines[i.identifier] = iMachine
			@machines[i.identifier].apply("touchmove", i)		
			

	broadcast: (name, eventObj) ->
		@analyser.notify(eventObj.identifier, name, eventObj)
##		$("debug").innerHTML = " Router: [" + name + "] " + dump(eventObj) + " \n " + $("debug").innerHTML
###
------------------------------------------------------------------------------------------------------------------------------ Analyser
###
## Methods helper
Object.swap = (obj1, obj2) ->
	temp = obj2
	obj2 = obj1
	obj1 = obj2

distanceBetweenTwoPoints = (x1, y1, x2, y2) -> 
	Math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))

getDirection = (deltaX, deltaY) ->
	if deltaX > 0 and deltaY < 0 ## Right top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then "right" else "up"
	if deltaX > 0 and deltaY > 0 ## Right bottom side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then "right" else "down"
	if deltaX < 0 and deltaY < 0 ## Left top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then "left" else "up"
	if deltaX < 0 and deltaY > 0 ## Left top side of the circle
		if Math.abs(deltaX) > Math.abs(deltaY) then "left" else "down"

## Finger Object which contains an Id, a gesture and all important parameters
## Params:
##		fingerId
##		gestureName
##		params
class FingerGesture
	constructor: (@fingerId, @gestureName, eventObj) ->
		date = new Date()
		@params = {}
		@params.startX = eventObj.clientX
		@params.startY = eventObj.clientY
		@params.timeStart = date.getTime()
		@params.timeElasped = 0
		@updatePosition(eventObj)

	update: (eventObj) ->
		date = new Date()
		@params.timeElasped = date.getTime() - @params.timeStart
		@updatePosition(eventObj)

	updatePosition: (eventObj) ->
		@params.x = eventObj.clientX
		@params.y = eventObj.clientY

class Analyser
	## Create an analyser object with total number of fingers and an array of all fingers as attribute
	constructor: (@totalNbFingers, @targetElement) ->
		@fingersArray = {}
	
	## Notify the analyser of a gesture (gesture name, fingerId and parameters of new position etc)
	notify: (fingerID, gestureName, params) ->
		if @fingersArray[fingerID]?
			@fingersArray[fingerID].update params
		else
			@fingersArray[fingerID] =  new FingerGesture(fingerID, gestureName, params)
		
		@analyse @totalNbFingers if _.size(@fingersArray) is @totalNbFingers
		
	
	## Redirect to the correct analysis method depending the number of finger	
	analyse: (nbFingers) ->
		switch nbFingers
			when 1 then @oneFingerGesture @fingersArray
			when 2 then @twoFingersGesture @fingersArray
			when 3 then @threeFingersGesture @fingersArray
			when 4 then @fourFingersGesture @fingersArray
			when 5 then @fiveFingersGeture @fingersArray
			else throw "We do not analyse more than 5 fingers"
			
	###----------------------------------------------------------------------------------------------------------------
	## One Finger Gesture
	###
	oneFingerGesture: ->
		for key of @fingersArray
			if @fingersArray.hasOwnProperty key
				finger = @fingersArray[key]

		switch finger.gestureName
			when "tap" then @targetElement.trigger "tap", finger.params
			when "doubleTap" then @targetElement.trigger "doubleTap", finger.params
			when "fixed" then @targetElement.trigger "fixed", finger.params
			when "drag"
				deltaX = finger.params.x - finger.params.startX
				deltaY = finger.params.y - finger.params.startY
				@targetElement.trigger getDirection(deltaX, deltaY), finger.params 
				
	###----------------------------------------------------------------------------------------------------------------
	## Two Finger Gesture
	###
	twoFingersGesture: ->
		## Gesture Name detection
		i = 0
		gestureName = ""
		for key of @fingersArray
			if @fingersArray.hasOwnProperty key
				i++
				firstFinger = @fingersArray[key] if i == 1
				secondFinger = @fingersArray[key] if i == 2
		gestureName = firstFinger.gestureName + "," + secondFinger.gestureName

		## Detection of finger order. First one will be the first from the left
		if firstFinger.params.x > secondFinger.params.x
			Object.swap firstFinger, secondFinger
		informations =
			first: firstFinger.params
			second: secondFinger.params
		switch gestureName
			when "tap,tap"
				informations.global = 
					distance: distanceBetweenTwoPoints firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y

				@targetElement.trigger "tap,tap", informations
				@targetElement.trigger "two:tap", informations
				
			when "fixed,drag", "drag,fixed"
				## Detection of finger order. First one will be the first from the left
				informations.global =
					distance: distanceBetweenTwoPoints firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y

				if firstFinger.gestureName == "fixed"
					deltaX = secondFinger.params.x - secondFinger.params.startX
					deltaY = secondFinger.params.y - secondFinger.params.startY
					@targetElement.trigger "fixed,#{getDirection(deltaX, deltaY)}", informations
				else 
					deltaX = firstFinger.params.x - firstFinger.params.startX
					deltaY = firstFinger.params.y - firstFinger.params.startY
					@targetElement.trigger "#{getDirection(deltaX, deltaY)},fixed", informations
			
			when "doubleTap,doubleTap"
				@targetElement.trigger "doubleTap,doubleTap", informations
				
			when "fixed,fixed"
				@targetElement.trigger "fixed,fixed", informations
				
			when "drag,drag"
				## Et c'est là qu'on souffre
				informations.global =
					distance: distanceBetweenTwoPoints firstFinger.params.x, firstFinger.params.y, secondFinger.params.x, secondFinger.params.y
				deltaX = secondFinger.params.x - secondFinger.params.startX
				deltaY = secondFinger.params.y - secondFinger.params.startY
				@targetElement.trigger "#{getDirection(deltaX, deltaY)},#{getDirection(deltaX, deltaY)}", informations
				
window.onload = ->	
	new EventRouter $("blue")
	$("blue").bind "fixed,down", (params) ->
		alert "??"
##		$("debug").innerHTML += params.second.x
	
