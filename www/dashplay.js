/**
 * Cordova DashPlay Plugin
 */


var PLUGIN_NAME = "DashPlay";

var DashPlay = function(){};

DashPlay.prototype.start = function(callback, url) {
    cordova.exec(callback, null, PLUGIN_NAME, "start", [url]);
}

if(!window.plugins)
    window.plugins = {};

if (!window.plugins.DashPlay)
    window.plugins.DashPlay = new DashPlay();

if (typeof module != 'undefined' && module.exports)
    module.exports = DashPlay;