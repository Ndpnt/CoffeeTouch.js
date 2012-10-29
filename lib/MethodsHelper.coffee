# Copyright (c) 2011
# Publication date: 06/17/2011
#   Pierre Corsini (pcorsini@polytech.unice.fr)
#   Nicolas Dupont (npg.dupont@gmail.com)
#   Nicolas Fernandez (fernande@polytech.unice.fr)
#   Nima Izadi (nim.izadi@gmail.com)
#   And supervised by Raphaël Bellec (r.bellec@structure-computation.com)

CoffeeTouch         = CoffeeTouch || {}
CoffeeTouch.Helper  = CoffeeTouch.Helper || {}
CoffeeTouch.Options = 
  preventDefault  : false
  flickSpeed      : 0.5
  flickTimeElapsed: 100

# Analyse all possible basic gesture of a single finger
# The unbind and trigger function have been taken from Backbone Framework.
# The onGesture function is inspired by the bind functon of Backbone Framework.
Element::onGesture = (eventName, callback, options) ->
  CoffeeTouch.Helper.mergeObjects(CoffeeTouch.Options, options)
  if !this.router?
    this.router = new EventRouter this
  calls = @_callbacks or @_callbacks = {}
  list = @_callbacks[eventName] or @_callbacks[eventName] = []
  list.push callback
  return this

Element::unbindGesture = (ev, callback) ->
  if !ev
    @_callbacks = {}
  else if calls = @_callbacks
    if !callback
      calls[ev] = []
    else
      list = calls[ev]
      if !list
        return this
      for callbackfunction, i in list
        if callback == callbackfunction
          list.splice(i, 1)
          break
  return this

Element::makeGesture = (ev) ->
  if !(calls = @._callbacks) then return this
  if list = calls[ev]
    for callbacFunction in list
      callbacFunction.apply(this, Array.prototype.slice.call(arguments, 1));

  if list = calls['all']
    for callbacFunction in list
      callbacFunction.apply(this, arguments)
  return this


# Returns true if the string contains the substring "it"
CoffeeTouch.Helper.stringContains = (str1, str2) ->
  str1.indexOf(str2) != -1;

# Returns true if the array contains the substring "it"
CoffeeTouch.Helper.arrayContains = (array, element) ->
  for el in array
    if (el == element) then return true
  return false

# Merge two hashes.
CoffeeTouch.Helper.mergeObjects = (destination, source) ->
  for property of source
    destination[property] = source[property] if source.hasOwnProperty property
  return destination


# Compute the distance between two poits
CoffeeTouch.Helper.distanceBetweenTwoPoints = (x1, y1, x2, y2) ->
  Math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))

# Returns a diretion regarding two given delta.
# @params
#   deltaX:   basicly: (currentX - lastX)
#   deltaY:   basicly: (currentY - lastY)
CoffeeTouch.Helper.getDirection = (deltaX, deltaY) ->
  if deltaX == deltaY == 0
    return "unknown"
  if Math.abs(deltaX) > Math.abs(deltaY)
    # Horizontal
    if deltaX < 0 then "left" else "right"
  else
    if deltaY < 0 then "up" else "down"

# Returns the direction of the given finger
CoffeeTouch.Helper.getDragDirection = (finger) ->
  deltaX = finger.params.x - finger.positions[finger.positionCount - 1].x
  deltaY = finger.params.y - finger.positions[finger.positionCount - 1].y
  CoffeeTouch.Helper.getDirection deltaX, deltaY

# Returns the litteral digit of the numeral digit
CoffeeTouch.Helper.digit_name = (->
  names = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten']
  (n) ->
    names[n])()

if jQuery?
  ( ($) ->
    $.fn.onGesture = (eventName, callback, options) ->
      return this.each (i, element) ->
        element.onGesture(eventName, callback, options)
    $.fn.unbindGesture = (eventName, callback) ->
      return this.each (i, element) ->
        element.unbindGesture(eventName, callback)
    $.fn.makeGesture = (eventName) ->
      return this.each (i, element) ->
        element.makeGesture(eventName)
  )(jQuery)
