# CoffeeTouch.js

CoffeeTouch.js is a multi-touch JavaScript library that allows you to create and handle easily your own multi touch gestures.

The library defines a naming convention to describe all possible gestures.


# Motivation

### [Hammer.js](http://eightmedia.github.com/hammer.js/), [Scripty2](http://scripty2.com/) ###

All those libraries suffer from the same limitation: the developer can only listen to predefined events, not create his own ones.

# Getting Started

Include CoffeeTouch.js in your web page and you're done. jQuery is not required. The functions are added directly to the Element object.

## Listening to a gesture

```JavaScript
$("#whiteboard").onGesture("tap,tap", function (event){
  alert("#whiteboard element has been taped with two fingers");
});
```

## Naming convention to describe gestures

A gesture is composed of one or more actions.

### Action names
Here is an exhaustive list of all possible actions:

#### Simple actions

With the following actions, you can construct gestures.

* __Tap__: when the user tap on the screen
    - `tap`: single tap
    - `doubletap`: double tap, like a double click
* __Hold__: when the user hold his fingers on the screen:
    - `fixed`: press and hold fingers on the screen
    - `fixedend`: release fingers after holding them.
* __Drag__: when the user move his fingers on the screen:
    - `drag`: any directional draging action
    - `up`: draging fingers upwards
    - `right`: draging fingers to the right
    - `down`: draging fingers downwards
    - `left`: draging fingers to the left
    - `dragend`: draging finished (user remove fingers from the screen)

#### Defined gestures

The following common gestures are already implemented.

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

## Provided function

All functions are added to the Element’s prototype.

**onGesture(gestureName, callbackFunction):**

Bind a callback to the gestureName passed in parameter.

```JavaScript
// Listening to a `tap`
$("#whiteboard").onGesture("tap", function (event){
    alert(“#whiteboard element has been taped with one finger");
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
    alert(“#whiteboard element has been taped with one finger");
});

// Listening to all events
$("#whiteboard").onGesture("all", function (name, event){
    alert(name + ' has been made on #whiteboard element');
});
```

# Dependencies

None.

# Compatibilities

* iOs
* Android 4.1+

# Examples

Try it online with your multitouch device! [Examples](https://github.com/Crozis/CoffeeTouch/wiki/Examples)

If you just want to *use the library*, skip to the [User's manual](https://github.com/Crozis/CoffeeTouch/wiki/CoffeeTouch---User's-Manual)


# Issues
Discovered a bug? Please create an issue here on GitHub!

[https://github.com/NicolasDupont/CoffeeTouch.js/issues](https://github.com/NicolasDupont/CoffeeTouch.js/issues)

## Contributors

- [Nicolas Dupont](http://ontherailsagain.com/authors/Nicolas)
- [Nima Izadi](http://ontherailsagain.com/authors/Nima)

### Participated in creation

- Raphaël Bellec
- Nicolas Fernandez
- Pierre Corsini
