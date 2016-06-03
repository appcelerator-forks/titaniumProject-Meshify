#Search need to be available in global variable in order the widget to access it
Alloy.Globals.searchBar =  $.searchBar
Alloy.Globals.doSearch = false
$.searchBar.addEventListener "return", (e) ->
  Alloy.Globals.flurry.logEvent "search",
    value: e.value
  
  if Titanium.Network.networkType is Titanium.Network.NETWORK_NONE
    Alloy.Globals.hideIndicator()
    alertDialog = Titanium.UI.createAlertDialog(
      title: "WARNING!"
      message: "Your device is not online."
      buttonNames: ["OK"]
    )
    alertDialog.show()
  else
    Alloy.Globals.firstRun = true
    Alloy.Globals.doSearch = true
    Alloy.Globals.lastSearchObj = Alloy.Globals.searchObj
    Alloy.Globals.searchObj = {
      searchTerm: e.value
      systemTypes: ""
      problemStatuses: ""
      customGroups: ""
      pageIndex: 0
      pageSize: 10
    }
    
    Ti.App.fireEvent 'search'
    
    Ti.API.info e
    $.searchBar.blur()

#Event listener for the menu tableView
$.menuTable.addEventListener 'click', (e) ->
  if e.rowData.id == "map"
    Ti.App.fireEvent 'changeMainView', {
      view : 'mapView'
    }
  else if e.rowData.id == "list"
    Ti.App.fireEvent 'changeMainView', {
      view : 'homeView'
    }
  else if e.rowData.id == "contact"
    Ti.App.fireEvent 'changeMainView', {
      view : 'contactView'
    }
  else if e.rowData.id == "logout"
    dialog = Ti.UI.createAlertDialog(
      cancel: 1
      buttonNames: [
        "Yes"
        "Cancel"
      ]
      message: "Are you sure you want to log out?"
      title: "Log Out"
    )
    dialog.show()
    dialog.addEventListener "click", (e) ->
      if e.index == 0
        Ti.App.Properties.setString 'username', null
        Ti.App.Properties.setString 'password', null
        Ti.App.Properties.setString 'rememberState', false
        
        Ti.App.fireEvent 'changeIndexView', {
          view : 'loginView'
        }
        
        Alloy.Globals.flurry.logEvent "logout",
          username: Ti.App.Properties.getString('username')
        
        #Indicator to clear the list view
        Alloy.Globals.clearTable = true
        Alloy.Globals.clearMapView = true
        
        Ti.App.fireEvent 'clearContent'
        
        #reset the search
        Alloy.Globals.doSearch = false
        Alloy.Globals.searchObj = {
          searchTerm: ""
          systemTypes: ""
          problemStatuses: ""
          customGroups: ""
          pageIndex: 0
          pageSize: 10
        }
  else
    Ti.API.info 'None of the menu buttons is clicked'
