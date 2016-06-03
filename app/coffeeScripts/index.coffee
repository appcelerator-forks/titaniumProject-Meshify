#This holds the controller that is currently added to the index window
currentView = undefined

#State of the remember button in login screen
rememberState = Ti.App.Properties.getBool('rememberState')

#Adding and removing controllers from the index window
showView = (view) ->
  if currentView
    $.index.remove currentView
  
  currentView = view
  $.index.add currentView
  _.each $.index.getChildren(), (e) ->
    Ti.API.info 'children: ' + JSON.stringify e
    

#Creating controllers that will be added and removed from the index window
loginView = Alloy.createController 'loginView'
mainView = Alloy.createController 'mainview'

#The index window need to be open first before any other window or view are attached to it
$.index.open()

#Shows the loading indicator
Alloy.Globals.showIndicator $.index, 'indexPage'

#Test to see if you are already logged in
url = Alloy.Globals.rootURL + "/api/authentication"

client = Ti.Network.createHTTPClient(

  # function called when the response data is available
  onload: (e) ->
    try
      data = JSON.parse(@responseText)
    catch e
      console.log e
      Alloy.Globals.hideIndicator $.index, 'indexPage'
      loginView.getView('wrapper').clearFields()
      showView loginView.getView()
      return
    Ti.API.info 'data: ' + JSON.stringify data
    if data.IsAuthenticated == true
      try
        Alloy.Globals.UserData = data
        Alloy.Globals.UserRole = data.roles
        Ti.API.info 'Alloy.Globals.UserData: ' + Alloy.Globals.UserData
        Ti.API.info 'Alloy.Globals.UserRole: ' + Alloy.Globals.UserRole
      catch e
        Ti.API.info e
        Alloy.Globals.hideIndicator $.index, 'indexPage'
        loginView.getView('wrapper').clearFields()
        showView loginView.getView()
        return
      
      Alloy.Globals.hideIndicator $.index, 'indexPage'
      
      mainView.getView().initiateNodesView()  
      showView mainView.getView()
      
    else
      Alloy.Globals.hideIndicator $.index, 'indexPage'
      loginView.getView('wrapper').clearFields()
      showView loginView.getView()
      
  # function called when an error occurs, including a timeout
  onerror: (e) ->
    Alloy.Globals.hideIndicator $.index, 'indexPage'
    if OS_IOS
      Alloy.Globals.flurry.logError "AutoLogin", "http error"
    else
      Alloy.Globals.flurry.onError "AutoLogin", "http error", ''
    Ti.API.info e.error 
    loginView.getView('wrapper').clearFields()
    showView loginView.getView()
    alert 'Error occured. Please try again'
    
  timeout: 10000 # in milliseconds
)
if Titanium.Network.networkType is Titanium.Network.NETWORK_NONE
  Alloy.Globals.hideIndicator $.index, 'indexPage'
  loginView.getView('wrapper').clearFields()
  showView loginView.getView()
else
  # Prepare the connection
  client.open "GET", url
  
  # Send the request.
  try
    if rememberState is true
      client.send()
    else
      Alloy.Globals.hideIndicator $.index, 'indexPage'
      loginView.getView('wrapper').clearFields()
      showView loginView.getView()
  catch e
    Ti.API.info e
        
#Global event listener for changing the views in the index window. The view that needs to be shown is passed as string.
Ti.App.addEventListener 'changeIndexView', (args) ->
  if args.view == 'mainView'
    mainView.mainView.hideMenu()
    showView mainView.getView()
    mainView.getView().initiateNodesView()
  if args.view == 'loginView'
    loginView.getView('wrapper').clearFields()
    showView loginView.getView()
    mainView.mainView.setDefaultView()
