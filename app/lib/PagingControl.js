var onScroll, onPostLayout;

function PagingControl(scrollableView){
       var pages = [];
       var page;
       var numberOfPages = 0;
 
        // Configuration
        var pageColor = "#231128";
	var container = Titanium.UI.createView({
		height: "20dp",
		width: Titanium.Platform.displayCaps.platformWidth,
		bottom: 0,
		left: "160dp",
		zIndex:1
	});
	// Keep a global reference of the available pages
	numberOfPages = scrollableView.getViews().length;
	
	pages = []; // without this, the current page won't work on future references of the module
	
	// Go through each of the current pages available in the scrollableView
	for (var i = 0; i < numberOfPages; i++) {
		page = Titanium.UI.createView({
			borderRadius: "6dp",
			width: "12dp",
			height: "12dp",
			left:  20 * i + "dp",
			backgroundColor: pageColor,
			opacity: 0.5
		});
		// Store a reference to this view
		pages.push(page);
		// Add it to the container
		container.add(page);
	}
	
	onScroll = function(event){
		// Go through each and reset it's opacity
		for (var i = 0; i < numberOfPages; i++) {
			pages[i].setOpacity(0.5);
		}
		// Bump the opacity of the new current page
		pages[event.currentPage].setOpacity(1);
		
	};
	 
	onPostLayout = function(event) {
		// Go through each and reset it's opacity
		for(var i = 0; i < numberOfPages; i++) {
			pages[i].setOpacity(0.5);
		}
		// Bump the opacity of the new current page
		pages[scrollableView.currentPage].setOpacity(1);
	 
	};

	// Mark the initial selected page
	pages[scrollableView.getCurrentPage()].setOpacity(1);
	// Attach the scroll event to this scrollableView, so we know when to update things
	scrollableView.addEventListener("scroll", onScroll);
        // Reset page control to default page when scollableView refresh
	scrollableView.addEventListener("postlayout", onPostLayout);
 
	return container;
};
  
module.exports = PagingControl;