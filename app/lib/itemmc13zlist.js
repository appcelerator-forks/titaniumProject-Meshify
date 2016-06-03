exports.getItem = function(args) {
	var color, colorPng, dateArray, error, item, mc13zrowLevel, mobile, role, timeArray, timestamp, timestampArray, _i, _j, _len, _len1, _ref;

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
			args.channels["mc13z.SS"].value = "Not Connected";
		}
		_i++;
	}

	timestamp = args.channels["mc13z.LM"].timestamp;

	if (timestamp.substring(0, 4) !== "Last") {
		args.channels["mc13z.LM"].timestamp = timestamp;
		timestampArray = timestamp.split(" ");
		dateArray = timestampArray[0].split("/");
		timeArray = timestampArray[1].split(":");
		args.channels["mc13z.LM"].timestamp = "Last Mist " + dateArray[0] + "/" + dateArray[1] + " " + timeArray[0] + ":" + timeArray[1] + " " + timestampArray[2];
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
			if (args.channels["mc13z.LVL"].value < 20) {
				args.channels["mc13z.LVL"].value = "Low";
			} else {
				args.channels["mc13z.LVL"].value = "OK";
			}
			break;
		}
	}

	if (mobile) {
		mc13zrowLevel = "Level: " + args.channels["mc13z.LVL"].value;
	} else {
		mc13zrowLevel = "Level: " + args.channels["mc13z.LVL"].value + "%";
	}

	item = [{
		detailView : args,
		nodecolormc13z : {
			image : colorPng
		},
		mc13zrowVanityName : {
			text : args.node.vanityname
		},
		mc13zrowAddress1 : {
			text : args.address.street1
		},
		mc13zrowAddress2 : {
			text : args.address.city + " " + args.address.state + " " + args.address.zip
		},
		mc13zrowConnected : {
			text : args.channels["mc13z.SS"].value,
			color : color
		},
		mc13zrowLevel : {
			color : "#090",
			text : mc13zrowLevel
		},
		mc13zrowLastMist : {
			text : args.channels["mc13z.LM"].timestamp
		},
		template : "itemmc13zlist"
	}];

	return item;

};
