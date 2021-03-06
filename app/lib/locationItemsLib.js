// Generated by CoffeeScript 1.6.2
exports.buildModels = function(dataObj, buildview, refreshControl) {
    var alertDialog, count, listlen, models, nodes, obj, _i, _len, _ref, _results;

    if (Titanium.Network.networkType === Titanium.Network.NETWORK_NONE) {
        if (OS_IOS) {
            // refreshControl.endRefreshing();
        }
        Alloy.Globals.hideIndicator();
        Ti.App.fireEvent('hideMapPull');
        alertDialog = Titanium.UI.createAlertDialog({
            title : "WARNING!",
            message : "Your device is not online.",
            buttonNames : ["OK"]
        });
        return alertDialog.show();
    } else {
        nodes = Alloy.Collections.nodes;
        listlen = dataObj.dataObj.list.length;
        count = 0;
        Alloy.headers = 0;
        models = new Array();
        _ref = dataObj.dataObj.list;
        _results = [];
        for ( _i = 0, _len = _ref.length; _i < _len; _i++) {
            obj = _ref[_i];
            _results.push((function(obj) {
                var client, e, macaddress, url;

                try {
                    macaddress = encodeURIComponent(obj.gateway.macaddress);
                } catch (_error) {
                    e = _error;
                    alert("No Devices at this Location");
                    return;
                }
                url = Alloy.Globals.rootURL + "/api/gateway?macaddress=" + macaddress;
                client = Ti.Network.createHTTPClient({
                    onload : function(e) {
                        var ModelList, data, datatemp, obja, _j, _len1;

                        try {
                            data = JSON.parse(this.responseText);
                        } catch (_error) {
                            e = _error;
                            if (OS_IOS) {
                                // refreshControl.endRefreshing();
                            }
                            Ti.App.fireEvent("hideMapPull");
                            Alloy.Globals.hideIndicator();
                            alert("Error Loading, please retry");
                            return "error";
                        }
                        if (data.isAuthenticated === false) {
                            alert("log me out");
                            if (OS_IOS) {
                                // refreshControl.endRefreshing();
                            }
                            Alloy.Globals.hideIndicator();
                            Ti.App.fireEvent('hideMapPull');
                            return "error";
                        } else {
                            datatemp = {
                                "labelData" : {
                                    "zip" : obj.address.zip,
                                    "state" : obj.address.state,
                                    "address" : obj.address.street1,
                                    "city" : obj.address.city,
                                    "first" : obj.person.first,
                                    "nodetemplate" : "nodeRowHeader",
                                    "last" : obj.person.last,
                                    "phone1" : obj.person.phone1,
                                    "mac" : obj.gateway.macaddress
                                }
                            };
                            datatemp = datatemp.labelData;
                            models.push(datatemp);
                            for ( _j = 0, _len1 = data.length; _j < _len1; _j++) {
                                obja = data[_j];
                                obja.template = "nodeRow";
                                obja.person = new Object;
                                obja.person = obj.person;
                                obja.address = new Object;
                                obja.address = obj.address;
                                if (obja.nodetemplate !== "mainMistaway") {
                                    models.push(obja);
                                }
                            }
                            count += 1;
                            if (count >= listlen) {
                                ModelList = models;
                                buildview(ModelList);
                                Ti.App.fireEvent('hideMapPull');
                            }
                        }
                    },
                    onerror : function(e) {
                        Ti.API.info(e.error);
                        if (OS_IOS) {
                            // refreshControl.endRefreshing();
                        }
                        Ti.App.fireEvent("hideMapPull");
                        Alloy.Globals.hideIndicator();
                        alert("Error Loading, please retry");
                        return "error";
                    },
                    timeout : 35000
                });
                client.open("GET", url);
                return client.send();
            })(obj));
        }
        return _results;
    }
};
