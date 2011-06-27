# CoffeeTouch - Multi-touch JavaScript Library

## Getting Started

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

### User's manual

See wiki for a more complete documentation:
https://github.com/Crozis/CoffeeTouch/wiki/CoffeeTouch---User's-Manual