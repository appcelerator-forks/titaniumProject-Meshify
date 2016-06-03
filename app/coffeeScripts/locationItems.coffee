


  
  
#this is the list of items at one location, not to be confused with a list of nodes nested under other locaitons   
exports.buildModels = (dataObj, buildview) ->
  if Titanium.Network.networkType is Titanium.Network.NETWORK_NONE
    Alloy.Globals.hideIndicator()
    alertDialog = Titanium.UI.createAlertDialog(
      title: "WARNING!"
      message: "Your device is not online."
      buttonNames: ["OK"]
    )
    alertDialog.show()
  else
    nodes = Alloy.Collections.nodes
    listlen = dataObj.list.length
    count = 0
    
   #check to make sure you have an internet connection 
     
    Alloy.headers = 0
    models = new Array()
    for obj in dataObj.list
      do (obj) ->
        try
          macaddress = encodeURIComponent(obj.gateway.macaddress)
        catch e
          alert "No Devices at this Location"
          return
        url = Alloy.Globals.rootURL + "/api/gateway?macaddress=" + macaddress
        client = Ti.Network.createHTTPClient(
        
          # function called when the response data is available
          onload: (e) ->
            try
              data = JSON.parse(@responseText)
            catch e
              Ti.App.fireEvent("hideMapPull")
              Alloy.Globals.hideIndicator()
              alert "Error Loading, please retry"
              return "error"
            if data.isAuthenticated == false
              alert "log me out"
              return "error"
            else
              #tempNode = new model()
              datatemp = {
                "labelData":
                  {
                    "zip": obj.address.zip
                    "state": obj.address.state
                    "address": obj.address.street1
                    "city": obj.address.city 
                    "first": obj.person.first
                    "nodetemplate": "nodeRowHeader"
                    "last": obj.person.last
                    "phone1": obj.person.phone1
                    "mac": obj.gateway.macaddress
                  }
                }
              
              datatemp = datatemp.labelData 
             
              models.push(datatemp)
              
              
              for obja in data
                obja.template = "nodeRow"
                obja.person = new Object
                obja.person = obj.person
                obja.address = new Object
                obja.address = obj.address
                if obja.nodetemplate != "mainMistaway"
                  #tempNode = new model()
                  #obja = JSON.flatten(obja)
                  models.push(obja)
                  
                  #obj.models.push(tempNode.parse(obja))
                  
              count += 1
              if count >= listlen
                
                
                
                #return dataObj.list
                ModelList = models
                #alert ModelList
                buildview ModelList
                return
                
          # function called when an error occurs, including a timeout
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
      