function SlideHelper(){};

//Creates alloy controller from the view that is passed as argument
SlideHelper.prototype.getViewController = function(view){
	return Alloy.createController(view);
};

//Returns the menu button which opens the slide menu
SlideHelper.prototype.getMenuButton = function(args){
	var v = Ti.UI.createView({
		height: args.h,
		width: args.w,
	});
	
	var b = Ti.UI.createView({
		height: "30dp",
		width: "35dp",
		//Menu Button Background Image
		backgroundImage: "/slideMenu/images/menu_button.png"
	});
	
	v.add(b);
	return v;
};

/*
	Setting up slide menu for the mainView
	
	Parameters:
	slideMenu the widget for the slide menu
*/
SlideHelper.prototype.setupSlideMenu = function(menuView) {
	// add event listener in this context
	menuView.menuTable.slideMenuHelper = this;
	
	// attach event listener to menu button
	mainView.menuButton.add(this.getMenuButton({ h:'60dp',w:'60dp'}));
	
	return slideMenu;
};

