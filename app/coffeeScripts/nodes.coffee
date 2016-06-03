JSON.flatten = (data) ->
  recurse = (cur, prop) ->
    if Object(cur) isnt cur
      result[prop] = cur
    else if Array.isArray(cur)
      i = 0
      l = cur.length

      while i < l
        recurse cur[i], prop + "[" + i + "]"
        i++
      result[prop] = []  if l is 0
    else
      isEmpty = true
      for p of cur
        isEmpty = false
        recurse cur[p], (if prop then prop + "." + p else p)
      result[prop] = {}  if isEmpty and prop
  result = {}
  recurse data, ""
  result
  

getdata = (searchTerm, systemTypes, problemStatuses, customGroups, pageIndex, pageSize) ->
  nodes = Alloy.Collections.nodes
  searchTerm = encodeURIComponent(searchTerm)
  systemTypes = encodeURIComponent(systemTypes)
  problemStatuses = encodeURIComponent(problemStatuses)
  customGroups = encodeURIComponent(customGroups)
  pageIndex = encodeURIComponent(pageIndex)
  pageSize = encodeURIComponent(pageSize)
  url = "http://imistaway.com/api/Locations?term=" + searchTerm + "&systemTypes=" + systemTypes + "&problemStatuses=" + problemStatuses + "&customGroups=" + customGroups + "&pageIndex=" + pageIndex + "&pageSize=" + pageSize 
  client = Ti.Network.createHTTPClient(
  
    # function called when the response data is available
    onload: (e) ->
      Ti.API.info "Received text: " + @responseText
      data = JSON.parse(@responseText)
      dataObj = new Object 
      dataObj.list = [] 
      data = data.CurrentPageListItems
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
        TempObj = node
        dataObj.list.push(TempObj)
      if data.isAuthenticated == false
        alert "you should log out"
      else if data.length == 0
        alert "no results" 
      else
        ModelList = buildModels dataObj
        for i in ModelList 
          nodes.add(i)
          

      
      #for i in data.CurrentPageListItems
        #i = JSON.flatten(i)
        #Ti.API.info i
        #test = new model(i)
        #nodes.add(test)
      #alert nodes.size()
    
    # function called when an error occurs, including a timeout
    onerror: (e) ->
      Ti.API.info e.error
      alert "error"
  
    timeout: 35000 # in milliseconds
  )
  
  # Prepare the connection.
  client.open "GET", url
  
  # Send the request.
  client.send()
  
  
  
buildModels = (dataObj) ->
    listlen = dataObj.list.length
    count = 0
    
   #check to make sure you have an internet connection 
     
    Alloy.headers = 0
    
    for obj in dataObj.list
      do (obj) ->
        obj.models = new Array()
        macaddress = encodeURIComponent(obj.gateway.macaddress)
        url = "http://imistaway.com/api/gateway?macaddress=" + macaddress
        client = Ti.Network.createHTTPClient(
        
          # function called when the response data is available
          onload: (e) ->
            Ti.API.info "Received text: " + @responseText
            data = JSON.parse(@responseText)
            if data.isAuthenticated == false
              alert "log me out"
            else
              tempNode = new model()
              datatemp = {
                zip: obj.address.zip
                state: obj.address.state
                address: obj.address.street1
                city: obj.address.city 
                first: obj.person.first
                nodetemplate: "nodeRowHeader"
                last: obj.person.last
                phone1: obj.person.phone1
                mac: obj.gateway.macaddress
                }
              datatemp = JSON.flatten(datatemp)
              Ti.API.info datatemp
              tempNode.parse(datatemp)
              #Meshable.headers += 1
              obj.models.push(tempNode)
              #Meshable.current_units.add tempNode
              
              for obja in data
                obja.person = new Object
                obja.person = obj.person
                obja.address = new Object
                obja.address = obj.address
                if obja.nodetemplate != "mainMistaway"
                  tempNode = new model()
                  obja = JSON.flatten(obja)
                  Ti.API.info obja
                  obj.models.push(tempNode.parse(obja))
                  #Meshable.current_units.add tempNode.parse(obja)
              count += 1
              if count >= listlen
                
                ###if count > 1
                  tempNode = new nodea { 
                    nodetemplate: "add"
                    }
                  Meshable.current_units.add tempNode###
                
                return dataObj.list
            
          
          # function called when an error occurs, including a timeout
          onerror: (e) ->
            Ti.API.info e.error
            alert "error"
        
          timeout: 35000 # in milliseconds
        )
        
        # Prepare the connection.
        client.open "GET", url
        
        # Send the request.
        client.send()

  
  
