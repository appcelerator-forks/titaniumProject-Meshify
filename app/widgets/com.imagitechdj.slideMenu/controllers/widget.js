var menuOpen = false;

exports.showHideMenu = function() {
	if (menuOpen) {
		moveTo = "0";
		menuOpen = false;
		Alloy.Globals.searchBar.blur();
	} else {
		moveTo = "250dp";
		menuOpen = true;
	}

	$.drawerMainView.width = Ti.Platform.displayCaps.platformWidth;
	$.drawerMainView.animate({
		left : moveTo,
		curve : Ti.UI.ANIMATION_CURVE_EASE_OUT,
		duration : 400
	});
};

Ti.Gesture.addEventListener('orientationchange', function(e) {
	$.drawerMainView.width = Ti.Platform.displayCaps.platformWidth;
});
