/**
 * Authors:	Nima Izadi - Nicolas Dupont 
 * Mail: nim.izadi@gmail.com - npg.dupont@gmail.com
 *
 * View
 */

window.sizeOfCanvas = 600;
window.Viewer = (function (){
	function Viewer(canvasDiv) {
		this.canvas = canvasDiv || document.getElementById("canvas");
	}
	
	/*
 	 * Returns a random color
 	 */
	Viewer.prototype.randomColor =  function () {
		var rand = Math.randomValue(200,100);
		return "rgba(" + 0 + "," + rand + "," + rand + ",1)";
	};
	
	/*
 	 * Returns a random color
 	 */
	Viewer.prototype.randomDarkColor =  function () {
		return "rgba(" + Math.randomValue(100) + "," + Math.randomValue(100) + "," + Math.randomValue(100) + ",1)";
	};

	/*
 	 * Display a colored line between the point a and the point b
 	 */
	Viewer.prototype.displayLine = function (x1,y1, x2,y2, color) {
		var context = this.canvas.getContext('2d');		
		context.lineWidth = 2;
		context.strokeStyle = color || "rgba(0,0,0,1)";
		context.beginPath();
		context.moveTo(x1, y1);
		context.lineTo(x2, y2);
		context.stroke();
		context.closePath();
	};
	
	/*
 	 * Display a colored point
 	 */
	Viewer.prototype.displayPoint = function (x,y, color, taille) {
		var context = this.canvas.getContext('2d');
		t = taille || 5;
		context.fillStyle = color || "rgba(0,0,0,1)";
		context.beginPath();
		context.arc(x, y, t, 0, Math.PI * 2,true);
		context.closePath();
		context.fill();
	};

	/*
	 * Display all points within the array passed in parameter
	 */
	Viewer.prototype.displayAllPoints = function (array) {
		var i;
		for(i = 0; i < array.length; i += 1) {
			this.displayPoint(array[i], this.randomColor());
		}
	};
	
	/*
 	 * Clears the canvas 
 	 */
	Viewer.prototype.clear = function () {
		var context = this.canvas.getContext('2d');
		this.canvas.width = this.canvas.width;
		context.clearRect(0, 0, canvas.width, canvas.height);
	};

	/*
 	 * Displays the closed path of a polygon with the array of polygon's vertices
 	 */
	Viewer.prototype.displayPolygon = function (pointsArray, color) {
		var k, color = color || "rgba(0,0,0,1)";
		if (pointsArray.length > 0) {
			for (k = 0; k < pointsArray.length; k+= 1) {
				this.displayLine(pointsArray[k], pointsArray[pointsArray.nextIndex(k)], color);
			}
		}
	};
	return Viewer;
})();
