###
 The bind, unbind and trigger function have been taken from Backbone Framework.
 The bind function has been changed
###

Element::bind = (eventName, callback) ->
	if !this.router?
		this.router = new EventRouter this
	calls = @_callbacks or @_callbacks = {}
	list = @_callbacks[eventName] or @_callbacks[eventName] = []
	list.push callback
	return this

Element::unbind = (ev, callback) ->
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

`
Element.prototype.trigger =  function(ev) {
	  var list, calls, i, l;
	  if (!(calls = this._callbacks)) return this;
	  if (list = calls[ev]) {
	    for (i = 0, l = list.length; i < l; i++) {
	      list[i].apply(this, Array.prototype.slice.call(arguments, 1));
	    }
	  }
	  if (list = calls['all']) {
	    for (i = 0, l = list.length; i < l; i++) {
	      list[i].apply(this, arguments);
	    }
	  }
	  return this;
	};
`

$ = (element) ->
	document.getElementById element

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
}
`
