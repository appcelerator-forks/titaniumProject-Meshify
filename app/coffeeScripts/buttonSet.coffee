


setChannel = (channels, macaddr, refresh) ->
  mac = new Array
  mac[0] = macaddr
  
  url = Alloy.Globals.rootURL + "/api/channel"
  
  client = Ti.Network.createHTTPClient(
  
    # function called when the response data is available
    onload: (e) ->
      try
        data = JSON.parse(@responseText)
      catch e
        Ti.API.info e
        Alloy.Globals.hideIndicator()
        alert "Error Sending Data, Please Try Again"
        return
      Ti.API.info data
      length = 0
      try
        if data[0].erroronset
          length = 2
      catch e
        length = 0
        
      if length > 0
        title = "Error Sending Data"
        msg = data[0].erroronset
      else 
        title = "SUCCESS"
        msg = "Success Sending the Command"
      dialog = Ti.UI.createAlertDialog(
        message: msg
        ok: "Okay"
        title: title
      )
      dialog.show()
      dialog.addEventListener "click", (e) ->
        Ti.API.info e
        if e.index == 0
          refresh()
          
      Alloy.Globals.hideIndicator()
      
      return
    # function called when an error occurs, including a timeout
    onerror: (e) ->
      Ti.API.info e.error
      Alloy.Globals.hideIndicator()
      alert "Error Sending Data, Please Try Again" 
      
  
    timeout: 35000 # in milliseconds
  )
  
  # Prepare the connection.
  client.open "POST", url
  client.setRequestHeader "content-type", "application/json; charset=utf-8"
  
  # Send the request.
  sendData = JSON.stringify({macaddresses: [macaddr], channelDTO: channels}) 
  Ti.API.info sendData
  client.send(sendData)

exports.setButton = (channelId, techName, fullName, mac, value, refresh) ->
  Alloy.Globals.flurry.logEvent "set",
    user: Ti.App.Properties.getString('username')
    techName: techName
    name: fullName
    mac: mac
    value: value
    userLog: (Ti.App.Properties.getString('username') + " " + techName + " " + fullName + " " + value)
  Alloy.Globals.showIndicator()
  if Titanium.Network.networkType is Titanium.Network.NETWORK_NONE
    Alloy.Globals.hideIndicator()
    alertDialog = Titanium.UI.createAlertDialog(
      title: "WARNING!" 
      message: "Your device is not online."
      buttonNames: ["OK"]
    )
    alertDialog.show()
  else
    Data = new Array
    localobj = 
      ChannelId: channelId
      value: value
      techName: techName
      name: fullName
    Data[0] = localobj
    setChannel Data, mac, refresh
    
    
    
    
    