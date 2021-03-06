// Generated by CoffeeScript 1.7.1
exports.refNode = function(Obj, mac, nodeId, tab) {
    var alertDialog, client, url;
    if (Titanium.Network.networkType === Titanium.Network.NETWORK_NONE) {
        Alloy.Globals.hideIndicator();
        alertDialog = Titanium.UI.createAlertDialog({
            title : "WARNING!",
            message : "Your device is not online.",
            buttonNames : ["OK"]
        });
        return alertDialog.show();
    } else {
        Alloy.Globals.showIndicator();
        url = Alloy.Globals.rootURL + "/api/gateway?macaddress=" + mac + "&nodeid=" + nodeId;
        client = Ti.Network.createHTTPClient({
            onload : function(e) {
                var data;
                data = JSON.parse(this.responseText);
                if (data.isAuthenticated === false) {
                    alert("log me out");
                    return "error";
                } else {
                    Obj.channels = data[0].channels;
                    Obj.problems = data[0].problems;
                    Obj.nodecolors = data[0].nodecolors;
                    Obj.lastcommunication = data[0].lastcommunication;
                    Obj.tab = tab;
                    Ti.App.fireEvent('changeMainView', {
                        view : 'detailsView',
                        e : Obj,
                        refresh : true
                    });
                    return Alloy.Globals.hideIndicator();
                }
            },
            onerror : function(e) {
                Ti.API.info(e.error);
                Ti.App.fireEvent("hideMapPull");
                Alloy.Globals.hideIndicator();
                alert("Error Loading, please retry");
                return "error";
            },
            timeout : 35000
        });
        client.open("GET", url);
        return client.send();
    }
}; 