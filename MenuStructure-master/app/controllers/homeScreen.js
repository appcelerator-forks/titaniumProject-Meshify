// create menu view
var data = [];

var v1 = Ti.UI.createView({
	height : '100%',
	width : '320dp',
	left : '0%',
	backgroundColor : '#212429'
});

$.drawermenu.drawermenuview.add(v1);

var tableView = Ti.UI.createTableView({
	top : '0%',
	height : Ti.UI.SIZE,
	width : '100%',
	scrollable : false,
	separatorColor : '#111214'
});
v1.add(tableView);

var sectionFlyUser = Ti.UI.createTableViewRow({
	height : '35dp',
	width : '100%',
	backgroundColor : '#212429',
	zIndex : 10
});

var imageFlyUser = Ti.UI.createView({
	left : '12dp',
	width : '27dp',
	height : '25dp',
	text : 'Comment',
	backgroundImage : "/images/comment-green.png"
});
sectionFlyUser.add(imageFlyUser);

var sectionPost = Ti.UI.createTableViewRow({
	height : '35dp',
	width : '100%',
	backgroundColor : '#212429',
	zIndex : 10
});

var imagePost = Ti.UI.createView({
	left : '12dp',
	width : '27dp',
	height : '25dp',
	text : 'Save',
	backgroundImage : "/images/save-gray.png"
});
sectionPost.add(imagePost);

var sectionInformation = Ti.UI.createTableViewRow({
	height : '35dp',
	width : '100%',
	backgroundColor : '#212429',
	zIndex : 10
});

var imageInformation = Ti.UI.createView({
	left : '12dp',
	width : '27dp',
	height : '25dp',
	text : 'Setting',
	backgroundImage : "/images/Setting.png"
});
sectionInformation.add(imageInformation);

var sectionLocations = Ti.UI.createTableViewRow({
	height : '35dp',
	width : '100%',
	backgroundColor : '#212429',
	zIndex : 10
});

var imageLocations = Ti.UI.createImageView({
	left : '12dp',
	width : '27dp',
	height : '25dp',
	text : 'User',
	backgroundImage : "/images/User.png"
});
sectionLocations.add(imageLocations);

var sectionGear = Ti.UI.createTableViewRow({
	height : '35dp',
	width : '100%',
	backgroundColor : '#212429',
	zIndex : 10
});

var imageGear = Ti.UI.createView({
	left : '12dp',
	width : '27dp',
	height : '25dp',
	text : 'On/Off',
	backgroundImage : "/images/on-off.png"
});
sectionGear.add(imageGear);

data.push(sectionFlyUser);
data.push(sectionPost);
data.push(sectionInformation);
data.push(sectionLocations);
data.push(sectionGear);

tableView.setData(data);

tableView.addEventListener('click', function(e) {
	if (e.row.children[0].text == 'Comment') {
		changeImage('comment-green', 'save-gray', 'Setting', 'User', 'on-off')
		var flyUserScreen = Alloy.createController('flyUserScreen').getView();
		$.drawermenu.drawermainview.add(flyUserScreen);
		$.drawermenu.showhidemenu();
	} else if (e.row.children[0].text == 'Save') {
		changeImage('comment', 'save', 'Setting', 'User', 'on-off')
		var commentScreen = Alloy.createController('commentScreen').getView();
		$.drawermenu.drawermainview.add(commentScreen);
		$.drawermenu.showhidemenu();
	} else if (e.row.children[0].text == 'Setting') {
		changeImage('comment', 'save-gray', 'Setting-green', 'User', 'on-off')
		var settingScreen = Alloy.createController('settingScreen').getView();
		$.drawermenu.drawermainview.add(settingScreen);
		$.drawermenu.showhidemenu();
	} else if (e.row.children[0].text == 'User') {
		changeImage('comment', 'save-gray', 'Setting', 'User-green', 'on-off')
		var profileScreen = Alloy.createController('profileScreen').getView();
		$.drawermenu.drawermainview.add(profileScreen);
		$.drawermenu.showhidemenu();
	} else if (e.row.children[0].text == 'On/Off') {
		changeImage('comment', 'save-gray', 'Setting', 'User', 'on-off-green')
		var onOffScreen = Alloy.createController('onOffScreen').getView();
		$.drawermenu.drawermainview.add(onOffScreen);
		$.drawermenu.showhidemenu();
	} else {
		$.drawermenu.showhidemenu();
	}
});

function changeImage(comment, save, setting, user, onOff) {
	imageFlyUser.backgroundImage = "/images/" + comment + ".png"
	imagePost.backgroundImage = "/images/" + save + ".png"
	imageInformation.backgroundImage = "/images/" + setting + ".png"
	imageLocations.backgroundImage = "/images/" + user + ".png"
	imageGear.backgroundImage = "/images/" + onOff + ".png"
}

var flyUserScreen = Alloy.createController('flyUserScreen').getView();
$.drawermenu.drawermainview.add(flyUserScreen);

Ti.App.addEventListener('settingImg', function(data) {
	$.drawermenu.showhidemenu();
});