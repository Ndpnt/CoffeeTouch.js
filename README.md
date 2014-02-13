# CoffeeTouch.js

CoffeeTouch.js is a multi-touch JavaScript library that allows you to create and handle easily your own multi touch gestures.

The library defines a naming convention to describe all possible gestures and provides functions to handle them.


## Motivation and benefits

This project began for the need of the company [Structure Computation](http://www.structure-computation.com/) to create a Web Application that allows to manipulate object in 3D visualization on iPad.

Some libraries already exist to handle multi-touch gestures and possibly resolve this problem like these ones:
	[jQuery Mobile](http://jquerymobile.com/),
	[Hammer.js](http://eightmedia.github.com/hammer.js/),
	[Scripty2](http://scripty2.com/),
	[Dojox Gesture](http://dojotoolkit.org/reference-guide/1.7/dojox/gesture.html#dojox-gesture),
	[Touchy](https://github.com/HotStudio/touchy),
	[TouchSwipe](http://labs.rampinteractive.co.uk/touchSwipe/demos/),
But all those libraries suffer from the same limitation: the developer can only listen to predefined events, not create his own ones.
Moreover, some of them come with many other features, they are heavy and library dependent.

So, benefits of CoffeTouch.js are the following:
- No dependencies.
- Lightweight.
- Easy to use.
- Allows developper to define his own gestures.

## Compatibilities

* iOs
* Android 4.1+

# Getting Started

Include CoffeeTouch.js in your web page and you're done. 

```HTML
<script src="CoffeeTouch.js"></script>
````

jQuery is not required, but CoffeeTouch.js is compatible with jQuery and embed a plugin for it.

## Listening to a gesture

### Examples

```JavaScript
document.getElementById("#whiteboard").onGesture("tap", function (event){
  alert("#whiteboard element has been taped with one finger");
});
```
```JavaScript
document.getElementById("#whiteboard").onGesture("doubleTap", function (event){
  alert("#whiteboard element has been double taped with one finger");
});
```
```JavaScript
document.getElementById("#whiteboard").onGesture("doubleTap, doubleTap", function (event){
  alert("#whiteboard element has been double taped with two fingers");
});
```

## Naming convention to describe gestures

A gesture is composed of one or more actions and an action is mapped to a finger.

### Action names
Here is an exhaustive list of all possible actions with which you can construct gestures:

* __Tap__: when the user tap on the screen
	- `tap`: single tap
	- `doubletap`: double tap, like a double click
* __Hold__: when the user hold his finger on the screen:
	- `fixed`: press and hold finger on the screen
	- `fixedend`: release finger after holding it.
* __Drag__: when the user move his finger on the screen:
	- `drag`: any directional draging action
	- `up`: draging finger upwards
	- `right`: draging finger to the right
	- `down`: draging finger downwards
	- `left`: draging finger to the left
	- `dragend`: draging finished (user remove finger from the screen)

#### Defined gestures
Coffeetouch comes with some common predifined gestures which are:

* __Pinch__: when the user bring his fingers closer or spread them.
	- `pinch`: bring fingers closer
	- `spread`: spread fingers
* __Flick__: when the user drag quickly on the screen
	- `flick`: a quick drag
	- `flick:direction`: flick in a particular direction (direction can be: `left`, `top`, `right`, `bottom`)
* __Rotation__: when the user rotate his fingers
	- `rotate`: any rotation
	- `rotate:cw`: clockwise rotation
	- `rotate:ccw`: counterclockwise rotation

### Defining a gesture

Gesture names are action names separated by a coma. Every action are mapped to specific the fingers touching the screen. First action will be map to the first finger, etc. (see [Fingers order convention](#fingers-order-convention) to understand how each finger is mapped to an action.). That way, you can compose any kind of gestures. Example:

* `up,up,up` means that three fingers are going upwards.
* `up,down,up` means that the first finger is going upwards, the second is going downwards, and the third going upwards.

For `pinch`, `spread` and `rotation`, you can specify the number of finger used by the user you can associate the number of fingers involved in the gesture. Ex.:

* `three:pinch`: pinch with three fingers
* `three:rotate`: rotate with three fingers

### Fingers order convention

Fingers are ordered in the Western reading direction (`left` to `right`, `up` to `down`).

If the gesture start horizontally, fingers will be ordered from left to right.

If the gesture start vertically, fingers will be ordered from top to bottom.

You can listen to gesture with more or less precision. If you listen a drag
gesture, every move of a finger will execute your callback function. But if you listen to a `left` gesture, your callback function will be execute only if the finger is moving to the left.

**Notice that order is considered in the gesture name**

# Configuration

## Options

You can pass a hash of options for third parameter.

The options are:

* `preventDefault` (default to `false`): prevent default behavior of browsers. For ex.: a double tap in iOS is a zoom, if preventDefault set to `true`, it won't zoom.
* `flickSpeed` (default to `0.5`): speed of the fingers movement to trigger the flick.
* `flickTimeElapsed` in ms (default to `100`): time elapsed between the moment the finger touch the screen and release from it.


## Event information object

When the `onGesture` function is called, an `event` hash is passed as parameter.

**event**:

* `rotation`: rotation value in degrees
* `scale`: scale factor between fingers (only defined for gestures with two or more fingers)
* `nbFingers`: number of fingers for the gesture
* `timeStart`: time when the gesture started
* `timeElapsed`: time elapsed from the beginning of the gesture (in ms)
* `fingers[nbFingers]`: _Each finger has its own informations._
	- `startX`: initial X position
	- `startY`: initial Y position
	- `x`: actual X position
	- `y`: actual Y position
	- `timeStart`: time when the finger has touched the screen
	- `timeElapsed`: time elapsed from the beginning of the touch (in ms)
	- `panX`: distance moved in X
	- `panY`: distance moved in Y
	- `speed`: speed of the finger
	- `gestureName`: name of the gesture (_tap, doubletap, fixed or drag_)
	- `dragDirection`: direction of the drag (if there is one) - _up, down, righ or left_

## Provided functions

All functions are added to the Element’s prototype.

**onGesture(gestureName, callbackFunction):**

Bind a callback to the gestureName passed in parameter.

```JavaScript
// Listening to a `tap`
$("#whiteboard").onGesture("tap", function (event){
	alert("#whiteboard element has been taped with one finger");
});
```

**unbindGesture(gestureName, callbackFunction):**

Remove the callback associated with the gestureName passed in parameter if it exists.

```JavaScript
var alertTap = function() {
	alert("I've been taped");
}
// Listen to tap
$("#whiteboard").onGesture("tap", alertTap);
// When #whiteboard is taped, `alertTap` function is called.

// Unbind `alertTap` function
$("#whiteboard").unbindGesture("tap", alertTap);
// `alertTap` won't be called if #whiteboard is taped.
```

**makeGesture(gestureName):**

Execute the callback associated with the gestureName if a gesture has been associated before. Like `trigger` in jQuery. Can be used to simulate a gesture.


```JavaScript
var alertTap = function() {
	alert("I've been taped");
}
// Listen to tap
$("#whiteboard").onGesture("tap", alertTap);
// When #whiteboard is taped, `alertTap` function is called.

// Unbind `alertTap` function
$("#whiteboard").makeGesture("tap");
// `alertTap` is called
```

### Listening to all events

If you want to listen to all events, the callback function will be called with two arguments:

- first: name
- second: eventParam

Example:

```JavaScript
// Listening to a `tap`
$("#whiteboard").onGesture("tap", function (event){
	alert("#whiteboard element has been taped with one finger");
});

// Listening to all events
$("#whiteboard").onGesture("all", function (name, event){
	alert(name + ' has been made on #whiteboard element');
});
```


# Examples

We've made some examples then you'll be able to test yourself the library online with your multitouch device:

- [Try some gestures](http://nicolasdupont.github.io/CoffeeTouch.js/examples/all/).
Try some basic gestures

- [Compose your gesture](http://nicolasdupont.github.io/CoffeeTouch.js/examples/try/).
Type / Compose your own gesture and test it!

- [Canvas example](http://nicolasdupont.github.io/CoffeeTouch.js/examples/canvas/).
    It's a drawing canvas in which you can do:

    - Double tap with one finger         Create a point
    - Tap with two fingers               Create two points
    - Flick down with three fingers      Clear the canvas
    - Tap with three fingers             Validate your drawing
    - Spread/Pinch with two fingers      Change the radius of selected point
    - Spread/Pinch with three fingers    Change the radius of unselected points

# Issues
Discovered a bug? Please create an issue here on GitHub!

[https://github.com/NicolasDupont/CoffeeTouch.js/issues](https://github.com/NicolasDupont/CoffeeTouch.js/issues)

# Contributors

- [Nicolas Dupont](http://ontherailsagain.com/authors/Nicolas)
- [Nima Izadi](http://ontherailsagain.com/authors/Nima)

### Participated in creation

- Raphaël Bellec
- Nicolas Fernandez
- Pierre Corsini

# License

The code for this software is distributed under the MIT License.
