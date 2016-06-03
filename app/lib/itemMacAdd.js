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

	Ti.API.info("####### here is the Item Mac Address Info");

	Ti.API.info(args);

	item = [{
		detailView : args,
		macAdd : {
			text : args.node.vanityname
		},
		panID : {
			text : args.address.street1
		},
		template : "itemmaclist"
	}];

	return item;
};