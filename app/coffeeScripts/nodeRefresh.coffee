


  
  
#this is the list of items at one location, not to be confused with a list of nodes nested under other locaitons   
exports.refNode = (Obj, mac, nodeId, tab) ->
  #check to make sure you have an internet connection 
  if Titanium.Network.networkType is Titanium.Network.NETWORK_NONE
    Alloy.Globals.hideIndicator()
    alertDialog = Titanium.UI.createAlertDialog(
      title: "WARNING!"
      message: "Your device is not online."
      buttonNames: ["OK"]
    )
    alertDialog.show()
  else
    Alloy.Globals.showIndicator()
    url = Alloy.Globals.rootURL + "/api/gateway?macaddress=" + mac + "&nodeid=" + nodeId 
    client = Ti.Network.createHTTPClient(
    
      # function called when the response data is available
      onload: (e) ->
        data = JSON.parse(@responseText)
        if data.isAuthenticated == false
          alert "log me out"
          return "error"
        else
          Obj.channels = data[0].channels
          Obj.problems = data[0].problems
          Obj.nodecolors = data[0].nodecolors
          Obj.lastcommunication = data[0].lastcommunication
          Obj.tab = tab
          Ti.App.fireEvent('goto:nodeDetials', Obj)
          
          Alloy.Globals.hideIndicator()
          
          
          
          
      onerror: (e) ->
        Ti.API.info e.error
         
        Ti.App.fireEvent("hideMapPull")
        
        Alloy.Globals.hideIndicator()
        alert "Error Loading, please retry"
        return "error"
        
      timeout: 35000 # in milliseconds
    )
    
    # Prepare the connection.
    
    client.open "GET", url
    
    # Send the request.
    client.send()
  