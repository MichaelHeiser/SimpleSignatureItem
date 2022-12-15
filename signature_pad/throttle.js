/* eslint-disable */
var _nextId = 0;
var _timers = {}

// used to add setTimeout() functionality
var _timerCreator = Qt.createComponent("PadTimer.qml");

function clearTimeout(timerId) {
    if (!_timers.hasOwnProperty(timerId)) {
        return;
    }
    var timer = _timers[timerId];
    timer.stop();
    timer.destroy();
    delete _timers[timerId];
}

function setTimeout(callback, timeout) {

    var tid = ++_nextId;

    var obj = _timerCreator.createObject(null, {interval: timeout});
    obj.triggered.connect(function() {
        try {
            callback();
        } catch (e) {
            console.warn(e);
        }
        obj.destroy();
        delete _timers[tid];
    });
    obj.running = true;
    _timers[tid] = obj;
    return tid;
}


// http://stackoverflow.com/a/27078401/815507
function throttle(func, wait, options) {
  var context, args, result;
  var timeout = null;
  var previous = 0;
  if (!options) options = {};
  var later = function () {
    previous = options.leading === false ? 0 : Date.now();
    timeout = null;
    result = func.apply(context, args);
    if (!timeout) context = args = null;
  };
  return function () {
    var now = Date.now();
    if (!previous && options.leading === false) previous = now;
    var remaining = wait - (now - previous);
    context = this;
    args = arguments;
    if (remaining <= 0 || remaining > wait) {
      if (timeout) {
        clearTimeout(timeout);
        timeout = null;
      }
      previous = now;
      result = func.apply(context, args);
      if (!timeout) context = args = null;
    } else if (!timeout && options.trailing !== false) {
      timeout = setTimeout(later, remaining);
    }
    return result;
  };
}
