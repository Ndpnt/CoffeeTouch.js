##	Functions helpers
## 		Analyse all possible basic gesture of a single finger
##
## Copyright (c) 2011
##		Pierre Corsini (pcorsini@polytech.unice.fr)
##		Nicolas Dupont (npg.dupont@gmail.com)
##		Nicolas Fernandez (fernande@polytech.unice.fr)
##		Nima Izadi (nim.izadi@gmail.com)	
##
## Permission is hereby granted, free of charge, to any person obtaining a 
## copy of this software and associated documentation files (the "Software"),
## to deal in the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense, 
## and/or sell copies of the Software, and to permit persons to whom the Software 
## is furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
## OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
## IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## The unbind and trigger function have been taken from Backbone Framework. 
## The onGesture function is inspired by the bind functon of Backbone Framework. 
Element::onGesture = (eventName, callback) ->
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
			list = calls[ev];
			if !list 
				return this
			for i in list
				if callback == list[i]
					list.splice(i, 1)
					break
	return this

Element::trigger = (ev) ->
	if !(calls = @._callbacks) then return this
	if list = calls[ev]
		for i in list
			i.apply(this, Array.prototype.slice.call(arguments, 1));

	if list = calls['all']
		for i in list
			i.apply(this, arguments)
	return this

String::contains = (it) ->
	this.indexOf(it) != -1;

Array::contains = (element) ->
	for el in this
		if (el == element) then return true
	return false

Object.merge = (destination, source) ->
	for property of source
		destination[property] = source[property] if source.hasOwnProperty property
	return destination
