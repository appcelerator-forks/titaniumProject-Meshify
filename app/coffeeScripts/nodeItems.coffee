


buildModels = (dataObj, buildview) ->
  
  Alloy.Globals.showIndicator()
  nodes = Alloy.Collections.nodes
  listlen = dataObj.list.length
  count = 0
  
 #check to make sure you have an internet connection 
   
  Alloy.headers = 0
 
  for obj in dataObj.list
    
    do (obj) ->
      obj.models = new Array()
      macaddress = encodeURIComponent(obj.gateway.macaddress)
      url = Alloy.Globals.rootURL + "/api/gateway?macaddress=" + macaddress
      client = Ti.Network.createHTTPClient(
      
        # function called when the response data is available
        onload: (e) ->
          try
            data = JSON.parse(@responseText)
          catch e
            Ti.App.fireEvent("hidePull")
            Alloy.Globals.hideIndicator()
            alert "Network Error, please retry"
            return "error"
          if data.isAuthenticated == false
            alert "Please Log In"
            Ti.App.fireEvent("logout")
            return
          
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
         
          obj.models.push(datatemp)
          
          
          for obja in data
            obja.template = "nodeRow"
            obja.person = new Object
            obja.person = obj.person
            obja.address = new Object
            obja.address = obj.address
            if obja.nodetemplate != "mainMistaway"
              #tempNode = new model()
              #obja = JSON.flatten(obja)
              obj.models.push(obja)
              
              #obj.models.push(tempNode.parse(obja))
              
          count += 1
          if count >= listlen
            
            
            
            #return dataObj.list
            #alert ModelList
            buildview dataObj.list
            return
              
        # function called when an error occurs, including a timeout
        onerror: (e) ->
          Ti.API.info e.error 
          Ti.App.fireEvent("hidePull")
          Alloy.Globals.hideIndicator()
          alert "Error Loading, please retry"
          return "error"
    
          
        timeout: 35000 # in milliseconds
      )
      
      # Prepare the connection.
      client.open "GET", url
      
      # Send the request.
      client.send()


exports.getdata = (buildview, searchTerm, systemTypes, problemStatuses, customGroups, pageIndex, pageSize) ->
  
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
  
   
    searchTerm = encodeURIComponent(searchTerm)
    systemTypes = encodeURIComponent(systemTypes)
    problemStatuses = encodeURIComponent(problemStatuses)
    customGroups = encodeURIComponent(customGroups)
    pageIndex = encodeURIComponent(pageIndex)
    pageSize = encodeURIComponent(pageSize)
    url = Alloy.Globals.rootURL + "/api/Locations?term=" + searchTerm + "&systemTypes=" + systemTypes + "&problemStatuses=" + problemStatuses + "&customGroups=" + customGroups + "&pageIndex=" + pageIndex + "&pageSize=" + pageSize 
    Ti.API.info url
    client = Ti.Network.createHTTPClient(
    
      # function called when the response data is available
      onload: (e) ->
        
        try
          data = JSON.parse(@responseText)
        catch e
          Alloy.Globals.hideIndicator()
          Ti.App.fireEvent("hidePull")
          alert "Network Error, Please Retry"
          return
        
        dataObj = new Object 
        dataObj.list = [] 
        data = data.CurrentPageListItems
        
       
        
        if data.isAuthenticated == false
          alert "Please Log In"
          Ti.App.fireEvent("logout")
          return
        
        
        
        if data.length < 1
          if Alloy.Globals.isScollLoad == true
            Alloy.Globals.isScollLoad = false
          else
            Alloy.Globals.doSearch = false
          alert "No Search Results"
          Alloy.Globals.searchObj = Alloy.Globals.lastSearchObj
          Alloy.Globals.hideIndicator()
          if Alloy.Globals.searchObj.pageIndex > 0 
            Ti.App.fireEvent("doneLoading")
          return
        Alloy.Globals.backbtn.hide()
        for node in data
          
          node.person.userRole = Alloy.userRole
          if node.person.first == ""
            node.person.first = "unknown" 
          if node.person.last == ""
            node.person.last = "unknown"
          if node.person.phone1 == ""
            node.person.phone1 = "000-000-0000"
          if node.address.city == ""
            node.address.city = "unknown"
          if node.address.state == ""
            node.address.state = "unknown"
          if node.address.street1 == ""
            node.address.street1 = "unknown"
          if node.address.zip == "" 
            node.address.zip = "unknown"
          dataObj.list.push(node)
        if data.length < 10
          Ti.App.fireEvent("doneLoading")
        else
          Ti.App.fireEvent("successLoading")

        
          
        buildModels dataObj, buildview
        return 
           
            
  
    
      
      # function called when an error occurs, including a timeout
      onerror: (e) ->
        Ti.API.info e.error
        Alloy.Globals.hideIndicator()
        Ti.App.fireEvent("hidePull")
        alert "Error Loading Data, Please Retry"
    
      timeout: 35000 # in milliseconds
    )
    
    # Prepare the connection.
    client.open "GET", url
    
    # Send the request.
    client.send() 
 
    
  

      