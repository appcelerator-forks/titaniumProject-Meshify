rootURL = Alloy.Globals.rootURL
Alloy.Globals.locDict = new Object

fit = require('/mapfitLib')
#This arrays are passed to mapfitLib for detecting the visible are on the map
latArray = []
longArray = []

location = require('locationItemsLib')

listView = $.list.getView()

Alloy.Globals.clearMapView = true

#This number is used to map the annotation
index = 0
dataObj = new Object()

#require the templates we are going to use
ItemGatelist = require("itemgatelist")
ItemMc13List = require("itemmc13list")
ItemMc13zList = require("itemmc13zlist")
ItemMc3List = require("itemmc3list")
ItemMc3zList = require("itemmc3zlist")

#This holds the annottations to reset them when changing views
annos = []
lastClickedMapAnnotation = null
if OS_ANDROID
  sections = []
  listState = null

#This object contains the last clicked section and item for scrolling the list to the correct place
lastVisibleItem = {
  item: 0
  section: 0
}

#Function that iterates through the list and creates rows for the table view according to the template provided
buildViewMap = (list) ->
  
  #Clear the sections array
  listView.setSections []
  sections = []
  
  #iterage over the list and add them to the table
  headerRow = false
    
  #Alloy.Globals.listLen1 = false
  for i in list
    Ti.API.info "adding node"
    Ti.API.info i.nodetemplate
    if i.nodetemplate == "nodeRowHeader"
      Ti.API.info "making new section"
      #Section for every row
      headerRow = Alloy.createController("sectionList", {
        headerTitle: (i.first + " " + i.last + "      " + i.phone1)
        fromMapView: true
      }).getView()
      
    else
      template = "item" + i.nodetemplate + "list"
      Ti.API.info 'template ' + template
      try
        switch template
          when "itemgatelist"
            headerRow.appendItems ItemGatelist.getItem(i)
          when "itemmc13list"
            headerRow.appendItems ItemMc13List.getItem(i)
          when "itemmc13zlist"
            headerRow.appendItems ItemMc13zList.getItem(i)
          when "itemmc3list"
            headerRow.appendItems ItemMc3List.getItem(i)
          when "itemmc3zlist"
            headerRow.appendItems ItemMc3zList.getItem(i)  
          else
            Ti.API.info 'template not supported'
              
      catch err  
        Ti.API.info err
        
  if Alloy.Globals.isScollLoad == true
    Alloy.Globals.isScollLoad = false
  
  listView.appendSection headerRow
  
  if OS_ANDROID
    sections.push headerRow
  
  #If only 1 node, skip to details view
  if list.length == 1
    if list[0].models.length == 2
      Alloy.Globals.listLen1 = true
      Ti.App.fireEvent 'changeMainView', {
        view: 'detailsView',
        e: list[0].models[1]
      }
  else
    expandList()
  
  if OS_IOS
    listView.refreshControl.endRefreshing()
  
  Alloy.Globals.hideIndicator()
  

#set the map location to the address of the user for start load
$.map.setRegion(
  latitude: Alloy.Globals.LATITUDE_BASE
  longitude: Alloy.Globals.LONGITUDE_BASE
  )

#Track user location
Titanium.Geolocation.getCurrentPosition (e) ->  
  if OS_IOS
    Alloy.Globals.flurry.setLatitude e.coords.latitude, e.coords.longitude, 10, 10 #set location stats (lat, lan, horz accuracy in meters, vert accuracy in meters)

$.zoomToMe.addEventListener "click", (e) ->
  collapseList()
  Titanium.Geolocation.getCurrentPosition (e) ->
    region =
      latitude: e.coords.latitude
      longitude: e.coords.longitude

    $.map.setLocation region

$.closeBtnView.addEventListener "swipe", (e) ->
  if e.direction == "down"
    collapseList()
$.closeBtnView.addEventListener "click", (e) ->
  collapseList()
  Ti.API.info JSON.stringify e

$.map.addEventListener "click", (e) ->
  Ti.API.info 'e ' + JSON.stringify(e)
  Ti.API.info 'e.clicksource ' + e.clicksource
  lastClickedMapAnnotation = e
  
  if e.clicksource == "infoWindow" or e.clicksource == "title" or e.clicksource == "rightButton"
    Alloy.Globals.showIndicator()
    Ti.API.info 'e.annotation.id ' + e.annotation.annoId
    node = Alloy.Globals.locDict[e.annotation.annoId]
    #Ti.API.info JSON.stringify(node)
    if OS_IOS
      try
        $.map.setLocation
          latitude: node.address.latitude
          longitude: node.address.longitude
      catch
        Ti.API.info e
        return

    dataObj = new Object 
    dataObj.list = []
    dataObj.list.push(node)
    e.dataObj = dataObj
    
    location.buildModels(e, buildViewMap, listView.refreshControl)
    
  if e.clicksource == "annotation" or e.clicksource == null or e.clicksource == "pin"
    collapseList()

#This function adds annotation to a map
addAnnotation = (geodata) ->
  Ti.API.info "here is the latitude"
  Ti.API.info geodata.latitude
  annotation = Alloy.createController "annotation", {
    annoId: geodata.id
    title: geodata.title
    latitude: geodata.coords.latitude
    longitude: geodata.coords.longitude
    image: if OS_IOS then geodata.image else undefined
    pincolor: if OS_ANDROID then geodata.pincolor else undefined
    rightButton: if OS_IOS then Titanium.UI.iPhone.SystemButton.DISCLOSURE else undefined
  }
  
  $.map.addAnnotation annotation.getView()
  
  #add the annottation to the annos array for reset when views are changing
  annos.push annotation.getView()
  
$.mapWrapper.reloadAnnotations = (e) ->
  if Titanium.Network.networkType is Titanium.Network.NETWORK_NONE
    Alloy.Globals.hideIndicator()
    alertDialog = Titanium.UI.createAlertDialog(
      title: "WARNING!"
      message: "Your device is not online."
      buttonNames: ["OK"]
    )
    alertDialog.show()
  else
    if Alloy.Globals.clearMapView
      $.map.removeAllAnnotations()
      annos = []
      Alloy.Globals.clearMapView = false
    searchTerm = Alloy.Globals.searchObj.searchTerm
    Alloy.Globals.showIndicator()
       
    xhr = Titanium.Network.createHTTPClient()
    xhr.onerror = (e) ->
      if OS_IOS
        Alloy.Globals.flurry.logError "MapLoad", "http error"
      else
        Alloy.Globals.flurry.onError "MapLoad", "http error", ''
      alert "error loading map data"
      Ti.API.error "Bad Sever =>" + e.error
      Alloy.Globals.hideIndicator()
    xhr.onload = (e) ->
      Alloy.Globals.locDict = new Object
      Alloy.Globals.showIndicator()
      latArray = []
      longArray = []
      #Ti.API.info "RAW =" + @responseText
      try
        data = JSON.parse(@responseText)
      catch e
        alert "Network Error, please try again"
        Alloy.Globals.hideIndicator()
        return
      #Ti.API.info data
      geodata = new Object
      if data.isAuthenticated == false
        alert "Please Log In"
        Ti.App.fireEvent("logout")
        return
      if data.length == 0
        alert "no results"
        Alloy.Globals.doSearch = false
        Alloy.Globals.searchObj = Alloy.Globals.lastSearchObj
        Alloy.Globals.hideIndicator()
        return
      if data.length == 1
        Alloy.Globals.listLen1 = true
      else 
        Alloy.Globals.listLen1 = false
      
      $.map.removeAllAnnotations()
      annos = []
      
      for i in data
         Ti.API.info index
         #this is how I map the locatoin object with the pin. Each pin has an index that will match with the key of the the data in locDict
         Alloy.Globals.locDict[index] = i
         
         #the index for the location
         geodata.id = index
         
         if i.nodecolors.statuscolor == "RED"
           if OS_IOS
             geodata.image = "/images/map_red_pin.png"
           else
             geodata.pincolor = Alloy.Globals.Map.ANNOTATION_RED
         else if i.nodecolors.statuscolor == "GREEN"
           if OS_IOS
             geodata.image = "/images/map_green_pin.png"
           else
             geodata.pincolor = Alloy.Globals.Map.ANNOTATION_GREEN
         else if i.nodecolors.statuscolor == "YELLOW"
           if OS_IOS
             geodata.image = "/images/map_yellow_pin.png"
           else
             geodata.pincolor = Alloy.Globals.Map.ANNOTATION_YELLOW
         else if i.nodecolors.statuscolor == "BLUE"
           if OS_IOS
             geodata.image = "/images/map_blue_pin.png"
           else
             geodata.pincolor = Alloy.Globals.Map.ANNOTATION_BLUE
         
         geodata.coords = new Object
         longArray.push(i.address.longitude)
         latArray.push(i.address.latitude)
         geodata.coords.latitude = i.address.latitude
         geodata.coords.longitude = i.address.longitude
         geodata.title = i.person.first + " " + i.person.last
         Ti.API.info "adding pin to the map"
         if OS_IOS
           Ti.API.info geodata.image
         else
           Ti.API.info i.nodecolors.statuscolor
         Ti.API.info i.address.latitude
         Ti.API.info i.address.longitude
         geodata.view = Alloy.createController("map_popup_view", i).getView()
         addAnnotation {
          id: index
          coords:
            latitude: i.address.latitude
            longitude: i.address.longitude
          image: if OS_IOS then geodata.image else undefined
          pincolor: if OS_ANDROID then geodata.pincolor else undefined
          title: geodata.title
          view: geodata.view
         }
         index += 1
        
      if data.length == 1
          $.map.setLocation
            latitude: i.address.latitude
            longitude: i.address.longitude
      else
        fit.setMarkersWithCenter($.map, latArray, longArray)
      Alloy.Globals.hideIndicator()
          
           
        
    xhr.setTimeout 120000
    xhr.open "GET", (Alloy.Globals.rootURL + '/api/locations?term=' + searchTerm )
    
    xhr.setRequestHeader "dataType", "json"
    xhr.setRequestHeader "content-type", "application/json"
    
    xhr.send()

if OS_IOS
  $.mapRefreshButton.addEventListener "click", (e) ->
    collapseList()
    $.mapWrapper.reloadAnnotations()

#This function shows the list
expandList = () ->
  Ti.API.info 'expandList'
  $.mapListView.animate(
    bottom: '0dp'
  )
  moveButtonsUp()
  if OS_ANDROID
    listState = true

#Expose the method
$.mapWrapper.expandList = expandList

#This function hides the list
collapseList = () ->
  Ti.API.info 'collapseList'
  $.mapListView.animate(
    bottom: '-220dp'
  )
  moveButtonsDown()
  if OS_ANDROID
    listState = false

#Expose the method
$.mapWrapper.collapseList = collapseList

#moving the location and refresh buttons on the map view upwards when the list view in the map opens so they can be visible on screen
moveButtonsUp = () ->
  if OS_IOS
    $.zoomToMe.animate(
      bottom : '225dp'
    )
    $.mapRefreshButton.animate(
      bottom : '225dp'
    )
  $.closeBtnView.animate(
    bottom : '220dp'
  )
  
#moving the location and refresh buttons on the map view downwards when the list view in the map opens so they can be visible on screen
moveButtonsDown = () ->
  if OS_IOS
    $.zoomToMe.animate(
      bottom : '5dp'
    )
    $.mapRefreshButton.animate(
      bottom : '5dp'
    )
  $.closeBtnView.animate(
    bottom : '-30dp'
  )

#This method reset the content of the map view when changing views
$.mapWrapper.setContent = () ->
  Ti.API.info 'setContent'
  Alloy.Globals.showIndicator()
  
  _.each annos, (e) ->
    #Ti.API.info 'annos: ' + e
    $.map.addAnnotation e
  
  fit.setMarkersWithCenter($.map, latArray, longArray)
  
  Alloy.Globals.hideIndicator()

#Removes the content on changing views in order to re-add them later to improve performance
$.mapWrapper.removeContent = () ->
  Ti.API.info 'removeContent'
  $.map.setAnnotations []

#This method reset the content of the list view in map view
$.mapWrapper.setListContent = () ->
  Ti.API.info 'setListContent'
  listView.setSections sections
  $.mapWrapper.setListPosition()

#This method shows the last view visible in the list
$.mapWrapper.setListPosition = () ->
  listView.scrollToItem lastVisibleItem.section, lastVisibleItem.item

if OS_ANDROID
  #This method is used to reset the content of the annottation
  $.mapWrapper.reload = ->
    if listState
      if lastClickedMapAnnotation
        $.map.fireEvent 'click', lastClickedMapAnnotation
    else
      $.mapWrapper.reloadAnnotations()

#Function that executes on itemList cilck
openDetails = (e) ->
  #Get the section of the clicked item
  section = listView.sections[e.sectionIndex]
  #Get the clicked item from that section
  item = section.getItemAt(e.itemIndex)
  
  #Set the last visible item to the one that has been clicked
  lastVisibleItem.item = e.itemIndex
  lastVisibleItem.section = e.sectionIndex
  
  Ti.App.fireEvent 'changeMainView', {
    view: 'detailsView',
    e: item.detailView
  }
  
#pull to refresh for ios
if OS_IOS
  listView.refreshControl.addEventListener 'refreshstart', () ->
    if lastClickedMapAnnotation
      $.map.fireEvent 'click', lastClickedMapAnnotation