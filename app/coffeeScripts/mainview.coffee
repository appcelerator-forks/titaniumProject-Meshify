#Set the main view to global variable so the loading indicator can be attach on this component
Alloy.Globals.mainViewContainer = $.mainView

#This contains the list view
homeView = Alloy.createController 'Home'

#This contains the map view
mapView = Alloy.createController 'map'

#This contains the contact view
contactView = Alloy.createController 'contact'

#This holds the current view that is added to the mainViewContainer
currentView = undefined

#This holds the current view as a string value
currentViewString = undefined

#This holds the view that needs to be set when the back button is clicked
backView = null

#This holds the view that needs to be set when going back from contact page in detail view
backViewSecondStage = null

#This holds the detail view component
detailView = null

mapViewShouldRefresh = false

nodesViewShouldRefresh = false

#This method calls the initiate method in nodes view which reloads the nodes list
$.mainView.initiateNodesView = ->
  $.mainView.setSwitchButtonToMap()
  $.backBtn.hide()
  if OS_ANDROID
    $.refreshBtn.show()
  homeView.container.initiateNodesView()

#Flag that hold the current visibility status of the slide menu.
menuOpen = false

#Flag that hold the value for animating. This will be '0dp' if the menu is open and '250dp' if the menu is closed
moveTo = false

#Method that show and hide the slide menu
$.menuView.showHideMenu = ->
  if menuOpen
    moveTo = "0"
    menuOpen = false
  else
    moveTo = "250dp"
    menuOpen = true
    
  $.mainViewContainerWrapper.setWidth Ti.Platform.displayCaps.platformWidth
  $.mainViewContainerWrapper.animate
    left : moveTo
    curve : Ti.UI.ANIMATION_CURVE_EASE_OUT
    duration : 400

if OS_ANDROID
  Alloy.Globals.refreshBtn = $.refreshBtn
  matrix = null
  a = null
      
  $.refreshBtn.addEventListener 'click', () ->
    matrix = Ti.UI.create2DMatrix()
    matrix = matrix.rotate(180)
    a = Ti.UI.createAnimation
      transform : matrix,
      duration : 1000,
    $.refreshBtn.animate a, ->
      matrix = Ti.UI.create2DMatrix()
      matrix = matrix.rotate(0)
      a = Ti.UI.createAnimation
        transform : matrix,
        duration : 0,
      $.refreshBtn.animate a
    
    Ti.API.info 'currentViewString ' + currentViewString
    switch currentViewString
      when "homeView"
        homeView.container.initiateNodesView()
      when "mapView"
        mapView.mapWrapper.reload()
      when "detailsView"
        #detailView
        Ti.API.info 'detail view'
        detailView.MAScrollView.pullLoad()
      else
        Ti.API.info 'refresh button error'

#This flag shows the current state of the switch button. 
#When this is set to false, the current state of the button is map, otherwise if it is set to true, the state of the button is list
switchButtonState = false

#This method sets the button to map
$.mainView.setSwitchButtonToMap = ->
    switchButtonState = false
    $.switchBtn.setBackgroundImage('/images/map.png')

#This method sets the button to list
$.mainView.setSwitchButtonToList = ->
    switchButtonState = true
    $.switchBtn.setBackgroundImage('/images/list.png')

#Event listener for the switch button
$.switchBtn.addEventListener "click", (e) ->
  menuOpen = true
  $.backBtn.hide()
  if switchButtonState
    Ti.App.fireEvent 'changeMainView', {
      view : 'homeView'
    }
  else
    Ti.App.fireEvent 'changeMainView', {
      view : 'mapView'
    }

#Event listener for the home button
$.homebtn.addEventListener "click", (e) ->
  $.switchBtn.show()
  menuOpen = true
  Alloy.Globals.firstRun = true
  Alloy.Globals.doSearch = false
  Alloy.Globals.searchObj = {
    searchTerm: ""
    systemTypes: ""
    problemStatuses: ""
    customGroups: ""
    pageIndex: 0
    pageSize: 10
  }
  
  switch currentViewString
    when "homeView"
      mapViewShouldRefresh = true
      Ti.App.fireEvent 'changeMainView', {
        view : 'homeView'
      }
    when "mapView"
      nodesViewShouldRefresh = true
      Ti.App.fireEvent 'changeMainView', {
        view : 'mapView'
      }
    else
      mapViewShouldRefresh = true
      Ti.App.fireEvent 'changeMainView', {
        view : 'homeView'
      }

#Event listener for the back button
$.backBtn.addEventListener "click", (e) ->
  Ti.API.info 'back button clicked'
  if backViewSecondStage
    $.mainView.showView backView
    if OS_ANDROID
      $.refreshBtn.show()
    backView = backViewSecondStage
    backViewSecondStage = null
    currentViewString = 'detailsView'
    Ti.API.info 'back view second stage'
  else
    $.mainView.showView backView
    $.switchBtn.show()
    if currentView == homeView.getView()
      if OS_ANDROID
        homeView.container.reSetNodesContent()
      else
        homeView.container.setListPosition()
      currentViewString = 'homeView'
    if currentView == mapView.getView()
      if OS_ANDROID
        mapView.mapWrapper.setListContent()
      else
        mapView.mapWrapper.setListPosition()
      mapView.mapWrapper.setContent()
      currentViewString = 'mapView'
        
    backView = null
    $.backBtn.hide()
    Ti.API.info 'back view'
    
    
#The showHideMenu function will be called upon a click on the menu button
$.menuButton.addEventListener 'click', $.menuView.showHideMenu

#If orientation changes set the width of the mainViewContainerWrapper to the current screen width
Ti.Gesture.addEventListener 'orientationchange', ->
  $.mainViewContainerWrapper.setWidth Ti.Platform.displayCaps.platformWidth

#Method that hides the menu
$.mainView.hideMenu = ->
  $.mainViewContainerWrapper.setWidth Ti.Platform.displayCaps.platformWidth
  $.mainViewContainerWrapper.setLeft '0dp'

#Method that set the default view in the mainViewController
$.mainView.setDefaultView = ->
  $.mainView.showView(homeView.getView())
  currentViewString = 'homeView'

#Method for adding and removing controllers from the main view
$.mainView.showView = (view) ->
  if currentView
    $.mainViewContainer.remove currentView
  
  currentView = view
  $.mainViewContainer.add currentView
  
  #Check how many views are added to the mainViewContainer
  _.each $.mainViewContainer.getChildren(), (e) ->
    Ti.API.info 'objects added to main view: ' + e

#Global event listener for changing the views in the index window. The view that needs to be shown is passed as string.
Ti.App.addEventListener 'changeMainView', (args) ->
  if currentView == mapView.getView()
    mapView.mapWrapper.removeContent()
  if args.view == 'homeView'
    Alloy.Globals.flurry.logEvent "homeView",
      page: "Home"
    $.backBtn.hide()
    $.switchBtn.show()
    if OS_ANDROID
      $.refreshBtn.show()
    if currentView != homeView.getView()
      $.mainView.showView homeView.getView() 
    if Alloy.Globals.firstRun or nodesViewShouldRefresh
      Alloy.Globals.firstRun = false
      nodesViewShouldRefresh = false
      $.mainView.initiateNodesView()
    else
      if OS_ANDROID
        homeView.container.reSetNodesContent()
      else
        homeView.container.setListPosition()
    $.mainView.setSwitchButtonToMap()
    $.menuView.showHideMenu()
    currentViewString = 'homeView'
  if args.view == 'mapView'
    Alloy.Globals.flurry.logEvent "mapView",
      page: "Map"
    $.backBtn.hide()
    $.switchBtn.show()
    if OS_ANDROID
      $.refreshBtn.show()
    if currentView != mapView.getView()
      $.mainView.showView mapView.getView()
    mapView.mapWrapper.collapseList()
    $.mainView.setSwitchButtonToList()
    $.menuView.showHideMenu()
    if Alloy.Globals.firstRun or mapViewShouldRefresh or Alloy.Globals.clearMapView
      Alloy.Globals.firstRun = false
      mapViewShouldRefresh = false
      mapView.mapWrapper.reloadAnnotations()
    else
      if OS_ANDROID
        mapView.mapWrapper.setListContent()
      else
        mapView.mapWrapper.setListPosition()
      mapView.mapWrapper.setContent()
    currentViewString = 'mapView'
  if args.view == 'contactView'
    Alloy.Globals.flurry.logEvent "pageView",
      page: "Contact"
    $.backBtn.show()
    if OS_ANDROID
      $.refreshBtn.hide()
    if detailView and detailView.getView() == currentView
      backViewSecondStage = backView
    backView = currentView
    $.mainView.showView contactView.getView()
    menuOpen = true
    $.menuView.showHideMenu()
    currentViewString = 'contactView'
  if args.view == 'detailsView'
    generateDetailView(args.e)
    #try to find it, if not, then we dont have it :)
    try
      if args.refresh
        $.mainView.showView detailView.getView()
      else
        backView = currentView
        $.mainView.showView detailView.getView()
      $.backBtn.show()
      $.switchBtn.hide()
      if OS_ANDROID
        $.refreshBtn.show()
      
      currentViewString = 'detailsView'
      Alloy.Globals.flurry.logEvent "detailView",
        page: "Details"
    catch err
      backView = null
      $.backBtn.hide()
      alert "This node type is not supported on this version of the app"
      Ti.API.info 'detail view error ' + err
      return

#make the name of the detail view we are searching for
generateDetailView = (e) ->
  for role in Alloy.Globals.UserRole
    Ti.API.info role
    if role == "MOBILE_ONLY"
      template = "MOBILE_ONLY" + e.nodetemplate + "Details"
      break
    else
      template = "ADMIN" + e.nodetemplate + "Details"
  Ti.API.info "current detail template " + template
  detailView = Alloy.createController template, e

#set Home controller as the current active view in mainView
$.mainView.setDefaultView()

#This listens for the search event and loads the appropriate view and refresh the data
Ti.App.addEventListener "search", () ->
  $.menuButton.fireEvent "click"
  switch currentViewString
    when "homeView"
      $.mainView.initiateNodesView()
    when "mapView"
      mapView.mapWrapper.reloadAnnotations()
    when "contactView"
      $.mainView.setDefaultView()
      $.mainView.initiateNodesView()
    when "detailsView"
      $.mainView.setDefaultView()
      $.mainView.initiateNodesView()
    else
      Ti.API.info 'Search error'

#Global event listener for removing the data in nodes view and map view
Ti.App.addEventListener 'clearContent', () ->
  mapView.mapWrapper.removeContent()
  homeView.container.clearListView()