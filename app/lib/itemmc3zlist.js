exports.getItem = function(args) {
	var color, colorPng, dateArray, error, item, mc3zrowLevel, mobile, role, timeArray, timestamp, timestampArray, _i, _j, _len, _len1, _ref;
	
	error =
	void 0;

	_i =
	void 0;

	_len =
	void 0;

	_i = 0;

	_len = args.problems.length;

	while (_i < _len) {
		error = args.problems[_i];
		if (error.priorityorder === 1 || error.priorityorder === 2) {
			args.channels["mc3z.SS"].value = "Not Connected";
		}
		_i++;
	}

	timestamp = args.channels["mc3z.LM"].timestamp;

	if (timestamp.substring(0, 4) !== "Last") {
		args.channels["mc3z.LM"].timestamp = timestamp;
		timestampArray = timestamp.split(" ");
		dateArray = timestampArray[0].split("/");
		timeArray = timestampArray[1].split(":");
		args.channels["mc3z.LM"].timestamp = "Last Mist " + dateArray[0] + "/" + dateArray[1] + " " + timeArray[0] + ":" + timeArray[1] + " " + timestampArray[2];
	}

Ti.API.info("////////////////////////Args////////////////////");
//Ti.API.info(args);

	Ti.API.info("####### here is the nodecolor");

	Ti.API.info(args.nodecolors.statuscolor);

	if (args.nodecolors.statuscolor === "GREEN") {
		colorPng = "/images/GREEN.png";
		color = "black";
	} else if (args.nodecolors.statuscolor === "RED") {
		color = "red";
		colorPng = "/images/RED.png";
	} else if (args.nodecolors.statuscolor === "YELLOW") {
		color = "yellow";
		colorPng = "/images/YELLOW.png";
	} else if (args.nodecolors.statuscolor === "BLUE") {
		color = "blue";
		colorPng = "/images/BLUE.png";
	} else if (args.nodecolors.statuscolor === "GRAY") {
		color = "gray";
	  	colorPng = "/images/GRAY.png";
	} else if (args.nodecolors.statuscolor === "UNKNOWN") {
		color = "gray";
	  	colorPng = "/images/DARKGRAY.png";
	} else {
		colorPng = "/images/BLUE.png";
		color = "black";
	}

	mobile = false;

	_ref = Alloy.Globals.UserRole;
	for ( _j = 0, _len1 = _ref.length; _j < _len1; _j++) {
		role = _ref[_j];
		Ti.API.info(role);
		if (role === "MOBILE_ONLY") {
			mobile = true;
			if (args.channels["mc3z.LVL"].value < 20) {
				args.channels["mc3z.LVL"].value = "LOW";
			} else {
				args.channels["mc3z.LVL"].value = "OK";
			}
			break;
		}
	}

	if (mobile) {
		mc3zrowLevel = "Level: " + args.channels["mc3z.LVL"].value;
	} else {
		mc3zrowLevel = "Level: " + args.channels["mc3z.LVL"].value + "%";
	}

	item = [{
		detailView : args,
		nodecolormc3z : {
			image : colorPng
		},
		mc3zrowVanityName : {
			text : args.node.vanityname
		},
		mc3zrowAddress1 : {
			text : args.address.street1
		},
		mc3zrowAddress2 : {
			text : args.address.city + " " + args.address.state + " " + args.address.zip
		},
		mc3zrowConnected : {
			text : args.channels["mc3z.SS"].value,
			color : color
		},
		mc3zrowLevel : {
			color : "#090",
			text : mc3zrowLevel
		},
		mc3zrowLastMist : {
			text : args.channels["mc3z.LM"].timestamp
		},
		template : "itemmc3zlist"
	}];

	return item;
};
