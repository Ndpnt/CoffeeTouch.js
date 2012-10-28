# CoffeeTouch - Multi-touch JavaScript Library

## Getting Started

Try it online with your multitouch device! [Examples](https://github.com/Crozis/CoffeeTouch/wiki/Examples)

If you just want to *use the library*, skip to the [User's manual](https://github.com/Crozis/CoffeeTouch/wiki/CoffeeTouch---User's-Manual)


### Simple example

	$("#my-element").onGesture("tap", function (event){
		... // Do something when a 'tap' on the DOM element called 'my-element' has been made.
	})


## Naming System

A gesture is composed of one or more actions. Here is an exhaustive list of all action possible:

* tap - doubletap
* fixed - fixedend
* drag - up - right - down - left - dragend
* flick - flick:direction
* pinch - spread
* rotate - rotate:cw - rotate:ccw

As you can see, you can listen to gesture with more or less precision. You are free to listen what you want. If you listen a drag gesture, every move of a finger will execute your callback function. But if you listen to a “left” gesture, your callback function will be execute only if the finger is moving to the left.
**Warning: Gesture names are separated by a single coma, but there is no blank space**

**Notice that order is considered in the gesture name**

You juste have to compose single action. For example:
 * “**up,up,up**” means that you are listening three fingers going up.
 * “**up,down,up**” means that you are listening the first finger going up, the second going down, and the third going up.

Notice that for pinch, spread and rotation, you can specify the number of finger used by the user. For doing that, you just have to specify a keyword number before the gesture keyword. Do as follow:

“**three:pinch**” will trigger only when the pinch will be done with three fingers.

## Fingers order
Fingers are ordered in the fingers array in the Western reading direction (left to right, up to down).

If the gesture seems to start horizontally, fingers will be ordered from left to right.

If the gesture seems to start vertically, fingers will be ordered from top to bottom.

## Event Information Object
**event**:

* rotation: Rotation value in degrees
* scale: Scale factor between fingers (only defined for gestures with two or more fingers)
* nbFingers: Number of fingers for the gesture
* timeStart: Time when the gesture started
* timeElapsed: Time elapsed from the beginning of the gesture (in ms)
* fingers[nbFingers]: _Each finger has its own informations._
 * startX: Initial X position
 * startY: Initial Y position
 * x: Actual X position
 * y: Actual Y position
 * timeStart: Time when the finger has touched the screen
 * timeElapsed: Time elapsed from the beginning of the touch (in ms)
 * panX: Distance moved in X
 * panY: Distance moved in Y
 * speed: Speed of the finger
 * gestureName: Name of the gesture (_tap, doubletap, fixed or drag_)
 * dragDirection: Direction of the drag (if there is one) - _up, down, righ or left_

## Other's function

**unbindGesture(gestureName, callbackFunction):**

This function is added to the Element’s prototype. Remove the callback associated with the gestureName passed in parameter if it exists.

**makeGesture(gestureName):**

This function is added to the Element’s prototype. Execute the callback associated with the gestureName if a gesture has been associated before.

### Important
If you want to bind to all events, the callback function will have two arguments:

- first: name
- second: eventParam

Example:

	$("#my-element").onGesture("all", function (name, event){
		...
	})


### User's manual

See wiki for a more complete documentation:
https://github.com/Crozis/CoffeeTouch/wiki/CoffeeTouch---User's-Manual


## Contributors

- (Nicolas Dupont)[http://ontherailsagain.com/authors/Nicolas]
- (Nima Izadi)[http://ontherailsagain.com/authors/Nima]

### Participated in creation

- Raphaël Bellec
- Nicolas Fernandez
- Pierre Corsini
