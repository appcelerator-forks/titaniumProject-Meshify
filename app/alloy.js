//set up analytics with flurry module
/*
if (OS_IOS) {
	Alloy.Globals.flurry = require("sg.flurry");
} else {
	Alloy.Globals.flurry = {};
}

if (OS_IOS) {
	//use https to send request to make them more safe
	Alloy.Globals.flurry.secureTransport(true);
	//logs exception in objective-c code
	Alloy.Globals.flurry.logUncaughtExceptions(true);
	//this only needs to be called once in the entire app
	Alloy.Globals.flurry.startSession("S38CK7M4YPSYKY3BQNP9");
	//logs a page view
	Alloy.Globals.flurry.logPageView();
} else {
	//For Android this need to be called on every activity(heavyweight window).
	//Alloy.Globals.flurry.onStartSession("TR9KFRGZX963N4F678DG");
	//logs a page view
	//Alloy.Globals.flurry.onPageView();
	//Alloy.Globals.flurry.setReportLocation(true);
	//Alloy.Globals.flurry.onEndSession();
	Alloy.Globals.flurry.onError = function(){};
	Alloy.Globals.flurry.setUserID = function(){};
	Alloy.Globals.flurry.logEvent = function(){};
}
*/
Alloy.Globals.dialogs = require('alloy/dialogs');

//Define default location
//TODO Need to be replaced with the current location from the GPS receiver
Alloy.Globals.LATITUDE_BASE = 37.389569;
Alloy.Globals.LONGITUDE_BASE = -122.050212;

//Define root URL and running state
Alloy.Globals.rootURL = "http://imistaway.com";
//Alloy.Globals.rootURL = "http://qa.meshify.com:82/";
//Alloy.Globals.rootURL = "http://qa.meshify.com";

Alloy.Globals.running = false;

//Define width of the screen
Alloy.CFG.width = Ti.Platform.displayCaps.platformWidth;

//Define half width of the screen
Alloy.CFG.halfWidth = Ti.Platform.displayCaps.platformWidth / 2;

//Define height of the screen
Alloy.CFG.height = Ti.Platform.displayCaps.platformHeight;

//Define half height of the screen
Alloy.CFG.halfHeight = Ti.Platform.displayCaps.platformHeight / 2;

//Change the width of the screen on orientation change
Ti.Gesture.addEventListener('orientationchange', function() {
  Alloy.CFG.width = Ti.Platform.displayCaps.platformWidth;
  Alloy.CFG.halfWidth = Ti.Platform.displayCaps.platformWidth / 2;
  Alloy.CFG.height = Ti.Platform.displayCaps.platformHeight;
  Alloy.CFG.halfHeight = Ti.Platform.displayCaps.platformHeight / 2;
});

if (OS_IOS || OS_ANDROID) {
	Alloy.Globals.Map = MapModule = Ti.Map = require('ti.map');
	if (OS_ANDROID) {
		var rc = MapModule.isGooglePlayServicesAvailable();
		switch (rc) {
		case MapModule.SUCCESS:
			Ti.API.info('Google Play services is installed.');
			break;
		case MapModule.SERVICE_MISSING:
			alert('Google Play services is missing. Please install Google Play services from the Google Play store.');
			break;
		case MapModule.SERVICE_VERSION_UPDATE_REQUIRED:
			alert('Google Play services is out of date. Please update Google Play services.');
			break;
		case MapModule.SERVICE_DISABLED:
			alert('Google Play services is disabled. Please enable Google Play services.');
			break;
		case MapModule.SERVICE_INVALID:
			alert('Google Play services cannot be authenticated. Reinstall Google Play services.');
			break;
		default:
			alert('Unknown error.');
			break;
		}
	}
}
var collection, model, nodes;

collection = Backbone.Collection.extend();

model = Backbone.Model.extend();

nodes = new collection();

nodes.trigger('change');

Alloy.Collections.nodes = nodes;

JSON.flatten = function(data) {
	var recurse, result;
	recurse = function(cur, prop) {
		var i, isEmpty, l, p;
		if (Object(cur) !== cur) {
			return result[prop] = cur;
		} else if (Array.isArray(cur)) {
			i = 0;
			l = cur.length;
			while (i < l) {
				recurse(cur[i], prop + "[" + i + "]");
				i++;
			}
			if (l === 0) {
				return result[prop] = [];
			}
		} else {
			isEmpty = true;
			for (p in cur) {
				isEmpty = false;
				recurse(cur[p], ( prop ? prop + "-" + p.replace('.', '-') : p));
			}
			if (isEmpty && prop) {
				return result[prop] = {};
			}
		}
	};
	result = {};
	recurse(data, "");
	return result;
};

//Activity Indicator.
var indWin = indWin = Alloy.createController('indicator').getView();

//Function to show the loading indicator on screen
Alloy.Globals.showIndicator = function(parentView, parent) {
	try {
		//if (indWin == null)
		//indWin = Alloy.createController('indicator').getView();
		indWin.showIndicator(parentView, parent);
	} catch(e) {
		Ti.API.info("Exception in opening indicator " + e.toString());
	}
};

//Function to hide the loading indicator
Alloy.Globals.hideIndicator = function(parentView, parent) {
	try {
		//if (indWin != null) {
		indWin.hideIndicator(parentView, parent);
		//indWin = null;
		//}
	} catch(e) {
		Ti.API.info("Exception in hiding indicator " + e.toString());
	}
};

/*
 * Date Format 1.2.3
 * (c) 2007-2009 Steven Levithan <stevenlevithan.com>
 * MIT license
 *
 * Includes enhancements by Scott Trenda <scott.trenda.net>
 * and Kris Kowal <cixar.com/~kris.kowal/>
 *
 * Accepts a date, a mask, or a date and a mask.
 * Returns a formatted version of the given date.
 * The date defaults to the current date/time.
 * The mask defaults to dateFormat.masks.default.
 */

var dateFormat = function() {
	var token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g, timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g, timezoneClip = /[^-+\dA-Z]/g, pad = function(val, len) {
		val = String(val);
		len = len || 2;
		while (val.length < len)
		val = "0" + val;
		return val;
	};

	// Regexes and supporting functions are cached through closure
	return function(date, mask, utc) {
		var dF = dateFormat;

		// You can't provide utc if you skip other args (use the "UTC:" mask prefix)
		if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
			mask = date;
			date = undefined;
		}

		// Passing date through Date applies Date.parse, if necessary
		date = date ? new Date(date) : new Date;
		if (isNaN(date))
			throw SyntaxError("invalid date");

		mask = String(dF.masks[mask] || mask || dF.masks["default"]);

		// Allow setting the utc argument via the mask
		if (mask.slice(0, 4) == "UTC:") {
			mask = mask.slice(4);
			utc = true;
		}

		var _ = utc ? "getUTC" : "get", d = date[_ + "Date"](), D = date[_ + "Day"](), m = date[_ + "Month"](), y = date[_ + "FullYear"](), H = date[_ + "Hours"](), M = date[_ + "Minutes"](), s = date[_ + "Seconds"](), L = date[_ + "Milliseconds"](), o = utc ? 0 : date.getTimezoneOffset(), flags = {
			d : d,
			dd : pad(d),
			ddd : dF.i18n.dayNames[D],
			dddd : dF.i18n.dayNames[D + 7],
			m : m + 1,
			mm : pad(m + 1),
			mmm : dF.i18n.monthNames[m],
			mmmm : dF.i18n.monthNames[m + 12],
			yy : String(y).slice(2),
			yyyy : y,
			h : H % 12 || 12,
			hh : pad(H % 12 || 12),
			H : H,
			HH : pad(H),
			M : M,
			MM : pad(M),
			s : s,
			ss : pad(s),
			l : pad(L, 3),
			L : pad(L > 99 ? Math.round(L / 10) : L),
			t : H < 12 ? "a" : "p",
			tt : H < 12 ? "am" : "pm",
			T : H < 12 ? "A" : "P",
			TT : H < 12 ? "AM" : "PM",
			Z : utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
			o : (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
			S : ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
		};

		return mask.replace(token, function($0) {
			return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
		});
	};
}();

// Some common format strings
dateFormat.masks = {
	"default" : "ddd mmm dd yyyy HH:MM:ss",
	shortDate : "m/d/yy",
	mediumDate : "mmm d, yyyy",
	longDate : "mmmm d, yyyy",
	fullDate : "dddd, mmmm d, yyyy",
	shortTime : "h:MM TT",
	mediumTime : "h:MM:ss TT",
	longTime : "h:MM:ss TT Z",
	isoDate : "yyyy-mm-dd",
	isoTime : "HH:MM:ss",
	isoDateTime : "yyyy-mm-dd'T'HH:MM:ss",
	isoUtcDateTime : "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
};

// Internationalization strings
dateFormat.i18n = {
	dayNames : ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
	monthNames : ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
};

// For convenience...
Date.prototype.format = function(mask, utc) {
	return dateFormat(this, mask, utc);
};
