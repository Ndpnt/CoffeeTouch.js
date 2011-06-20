# CoffeeTouch - Multi-touch JavaScript Library

## Getting Started

To compile in javascript file:
'coffee -c -j CoffeeTouch MethodsHelper.coffee StateMachine.coffee Finger.coffee EventRouter.coffee AnalyzerHelper.coffee Analyzer.coffee'

### Simple example: 
	document.getElementById("myElement").onGesture("two:tap", function (event){
		...
	})

### Important:
If you want to bind to all events, the callback function will have two arguments:
	first: name
	second: eventParam
Example:
	document.getElementById("myElement").onGesture("all", function (name, event){
		...
	})

### User's manual

See wiki for a more complete documentation:
https://github.com/Crozis/CoffeeTouch/wiki/CoffeeTouch---User's-Manual