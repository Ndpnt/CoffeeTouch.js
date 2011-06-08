(function() {
  var Analyser, FingerGesture;
  FingerGesture = (function() {
    function FingerGesture(fingerId, gestureName, params) {
      this.fingerId = fingerId;
      this.gestureName = gestureName;
      this.params = params;
    }
    FingerGesture.prototype.update = function(params) {};
    return FingerGesture;
  })();
  Analyser = (function() {
    function Analyser(totalNbFingers, targetElement) {
      this.totalNbFingers = totalNbFingers;
      this.targetElement = targetElement;
      this.fingersArray = {};
    }
    Analyser.prototype.notify = function(fingerID, gestureName, params) {
      if (this.fingersArray[fingerID] != null) {
        this.fingersArray[fingerID].update(params);
      } else {
        this.fingersArray[fingerID] = new FingerGesture(fingerId, gestureName, params);
      }
      return this.analyse(this.totalNbFingers);
    };
    Analyser.prototype.analyse = function(nbFingers) {
      switch (nbFingers) {
        case 1:
          return this.oneFingerGesture(this.fingersArray);
        case 2:
          return this.twoFingersGestures(this.fingersArray);
        case 3:
          return this.threeFingersGestures(this.fingersArray);
        case 4:
          return this.fourFingersGestures(this.fingersArray);
        case 5:
          return this.fiveFingersGetures(this.fingersArray);
        default:
          throw "We do not analyse more than 5 fingers";
      }
    };
    Analyser.prototype.oneFingerGesture = function(fingersArray) {
      var finger, key;
      for (key in obj) {
        if (obj.hasOwnProperty(key)) {
          finger = obj[key];
        }
      }
      switch (finger.gestureName) {
        case "tap":
          return alert("I've been tapped");
        case "doubleTap":
          return targetElement.trigger("doubleTap");
        case "fixed":
          return targetElement.trigger("fixed");
        case "drag":
          return targetElement.trigger("drag");
      }
    };
    return Analyser;
  })();
  window.onload = function() {
    var analyser;
    analyser = new Analyser(1, $('blue'));
    return analyser.update(4, "tap", {
      x: 10,
      y: 12
    });
  };
}).call(this);
