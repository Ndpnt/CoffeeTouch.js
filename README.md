# CoffeeTouch - Multi-touch JavaScript Library

## Getting Started

Try it online with your multitouch device! (Multitouch works only(?) on iPad) [Examples](https://github.com/Crozis/CoffeeTouch/wiki/Examples)

If you just want to *use the library*, skip to the [User's manual](https://github.com/Crozis/CoffeeTouch/wiki/CoffeeTouch---User's-Manual)

If you want to *fork or improve* the library:
[CoffeeScript](http://jashkenas.github.com/coffee-script/) is required

To compile in javascript file:

`coffee -c -j CoffeeTouch MethodsHelper.coffee StateMachine.coffee Finger.coffee EventRouter.coffee AnalyzerHelper.coffee Analyzer.coffee`

### Simple example

	document.getElementById("myElement").onGesture("tap", function (event){
		... // Do something when a 'tap' on the DOM element called 'myElement' has been made.
	})

### Important
If you want to bind to all events, the callback function will have two arguments:

- first: name
- second: eventParam

Example:

	document.getElementById("myElement").onGesture("all", function (name, event){
		...
	})

Events functions have been taken from Backbone and have been added to Element's prototype.
You can refer to [Backbone Events](http://documentcloud.github.com/backbone/#Events).

### User's manual

See wiki for a more complete documentation:
https://github.com/Crozis/CoffeeTouch/wiki/CoffeeTouch---User's-Manual