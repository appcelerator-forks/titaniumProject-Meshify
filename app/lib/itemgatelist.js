exports.getItem = function(args) {
	var colorPng, error, item, _i, _len;

	error =
	void 0;

	_i =
	void 0;

	_len =
	void 0;

	_i = 0;

	_len = args.problems.length;

	Ti.API.info("####### here is the nodecolor");

	Ti.API.info(args.nodecolors.statuscolor);

	if (args.nodecolors.statuscolor === "GREEN") {
		colorPng = "/images/GREEN.png";
	} else if (args.nodecolors.statuscolor === "RED") {
		colorPng = "/images/RED.png";
	} else if (args.nodecolors.statuscolor === "YELLOW") {
		colorPng = "/images/YELLOW.png";
	} else if (args.nodecolors.statuscolor === "BLUE") {
		colorPng = "/images/BLUE.png";
	} else if (args.nodecolors.statuscolor === "GRAY") {
	  colorPng = "/images/GRAY.png";
	} else if (args.nodecolors.statuscolor === "UNKNOWN") {
	  colorPng = "/images/GRAY.png";
	} else {
		colorPng = "/images/BLUE.png";
	}

	item = [{
		detailView : args,
		nodeColorGate : {
			image : colorPng
		},
		gateRowVanityName : {
			text : args.node.vanityname
		},
		gateRowAddress1 : {
			text : args.address.street1
		},
		gateRowAddress2 : {
			text : args.address.city + " " + args.address.state + " " + args.address.zip
		},
		template : "itemgatelist"
	}];

	return item;
};