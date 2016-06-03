$.activityInd.style = Titanium.UI.iPhone.ActivityIndicatorStyle.BIG  if Ti.Platform.osname is "ipad"

#Function to show the indicator
$.container.showIndicator = (parentView, parent) ->
  try
    if parent == 'indexPage'
      parentView.add($.container)
    else if parent == 'loginPage'
      parentView.add($.container)
    else
      if Alloy.Globals.mainViewContainer
        Alloy.Globals.mainViewContainer.add($.container)
    $.activityInd.show()
    #$.container.open()
    Ti.API.info "Indicator opened"
  catch e
    Ti.API.info "Exception IN opening indicator " + e.toString()
  return


#Function to hide indicator
$.container.hideIndicator = (parentView, parent) ->
  try
    if parent == 'indexPage'
      parentView.remove($.container)
    else if parent == 'loginPage'
      parentView.remove($.container)
    else
      if Alloy.Globals.mainViewContainer
        Alloy.Globals.mainViewContainer.remove($.container)
    $.activityInd.hide()
    #$.container.close()
    Ti.API.info "Indicator closed"
  catch e
    Ti.API.info "Exception IN hiding indicator " + e.toString()
  return

#This function is called when back button is pressed on Android. This prevents the indicator to be removed on back button click.
#disableBackButton = () ->
  #return false