// Public Domain (-) 2014 The Mu Authors.
// See the Mu UNLICENSE file for details.

/* global performance, define, exports, module, Symbol, WeakMap, MU_DEV_MODE */

function mu() {
  'use strict';

  var $Object = Object,
      create = $Object.create,
      defProp = $Object.defineProperty,
      defProps = $Object.defineProperties,
      getKeys = $Object.keys,
      hasProp = {}.hasOwnProperty,
      isArray = Array.isArray,
      now = Date.now,
      objProto = $Object.prototype,
      $ = {},
      clock,
      detectors = {},
      features = {},
      latest = now(),
      perf,
      settings = {},
      skew = 0,
      symID = 1,
      symPrefix = rand() + '_',
      weakID = 1,
      weakPrefix = '__weak_' + rand() + '_',
      Sym,
      Weak;

  if (typeof Symbol === 'undefined') {
    Sym = function(name) {
      var sym = 'Symbol(' + (name || '') + ')[' + symPrefix + symID++ + ']';
      defProp(objProto, sym, {set: genSymbolSetter(sym)});
      return sym;
    };
  } else {
    Sym = Symbol;
  }

  function genSymbolSetter(sym) {
    return function(value) {
      defProp(this, sym, {
        configurable: true,
        value: value,
        writable: true
      });
    };
  }

  if (typeof WeakMap === 'undefined') {
    Weak = function() {
      if (!(this instanceof Weak)) {
        return new Weak();
      }
      this.id = weakPrefix + weakID++;
      this.data = {};
      this.ptr = 0;
    };
    extend(Weak.prototype, {
      delete: function(obj) {
        var ptr = obj[this.id];
        delete obj[this.id];
        delete this.data[ptr];
      },
      get: function(obj) {
        return this.data[obj[this.id]];
      },
      has: function(obj) {
        return obj[this.id] !== undefined;
      },
      set: function(obj, value) {
        var ptr = obj[this.id];
        if (ptr) {
          this.data[ptr] = value;
          return;
        }
        this.data[this.ptr] = value;
        defProp(obj, this.id, {
          configurable: true,
          value: "" + this.ptr++
        });
      }
    });
  } else {
    Weak = WeakMap;
  }

  if (typeof performance !== 'undefined' && (perf = performance).now) {
    clock = function() {
      return perf.now();
    };
  } else {
    clock = function() {
      var time = now();
      if (time < latest) {
        skew += latest - time + 1;
      }
      latest = time;
      return time + skew;
    };
  }

  function config(obj, value) {
    var i, k, keys, l;
    if (value === void 0) {
      return settings[obj];
    }
    if (typeof obj === 'object') {
      for (keys = getKeys(), i = 0, l = keys.length; i < l; i++) {
        settings[k = keys[i]] = obj[k];
      }
    } else {
      settings[obj] = value;
    }
  }

  function detect(feature, detector) {
    if (detector === void 0) {
      var status = features[feature];
      if (status === void 0) {
        detector = detectors[feature];
        if (detector !== void 0) {
          return (features[feature] = detector());
        }
      }
      return status;
    }
    detectors[feature] = detector;
  }

  // function equals(left, right) {
  // }

  function extend(obj, items) {
    var keys = getKeys(items), i, key, l = keys.length;
    for (i = 0; i < l; i++) {
      obj[key = keys[i]] = items[key];
    }
  }

  // function View(name, spec) {
  // }

  // Utility functions.

  // TODO(tav): Care needs to be taken when cloning objects with descriptors,
  // e.g. getters/setters.
  function clone(obj) {
    var i, key, keys, l, n;
    if (isArray(obj)) {
      n = [];
      for (i = 0, l = obj.length; i < l; i++) {
        n.push(clone(obj[i]));
      }
      return n;
    }
    if (typeof obj === 'object' && obj !== null) {
      n = {};
      for (i = 0, keys = getKeys(obj), l = obj.length; i < l; i++) {
        n[key = keys[i]] = clone(obj[key]);
      }
      return n;
    }
    return n;
  }

  function rand() {
    return Math.random().toString().slice(2);
  }

  return {
    // Potential polyfills.
    Symbol: Sym,
    WeakMap: Weak,
    // Constructors.
    // View: View,
    // Element constructors.
    $: $,
    //
    // equals: equals,
    // Time-related utilities.
    clock: clock,
    now: now,
    // Other utilities.
    config: config,
    detect: detect,
    extend: extend
  };

}

if (typeof exports === 'object') {
  module.exports = mu();
} else if (typeof define === 'function' && define.amd) {
  define(mu);
} else {
  // Assume a browser-like global environment.
  (function(root) {
    root.$ = (root.mu = root['µ'] = mu()).$;
  }(this));
}
