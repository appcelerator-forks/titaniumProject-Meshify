exports.getItem = function(args) {
	var color, colorPng, dateArray, error, item, emptyrowLevel, mobile, role, timeArray, timestamp, timestampArray, _i, _j, _len, _len1, _ref;

	error =
	void 0;

	_i =
	void 0;

	_len =
	void 0;

	_i = 0;


Ti.API.info("////////////////////////Args////////////////////");
Ti.API.info(args);


	color = "gray";
  	colorPng = "/images/DARKGRAY.png";

	mobile = false;


	item = [{
		detailView : "",
		nodecolorempty : {
			image : colorPng
		},
		emptyrowVanityName : {
			text : "UNKNOWN"
		},
		emptyrowAddress1 : {
			text : args.address
		},
		emptyrowAddress2 : {
			text : args.city + " " + args.state + " " + args.zip
		},
		/*
		emptyrowConnected : {
			text : "",
			color : color
		},
		emptyrowLevel : {
			color : "#090",
			text : emptyrowLevel
		},
		mc13zrowLastMist : {
			text : args.channels["mc13z.LM"].timestamp
		},
		*/
		template : "itememptylist"
	}];

	return item;

};
