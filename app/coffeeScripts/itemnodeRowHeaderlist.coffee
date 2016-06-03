args = arguments[0] or {}
Ti.API.info args
$.labelRowPhone.text = args.phone1

lastNameFirstName = args.last + ", " + args.first

if lastNameFirstName.length > 15
  $.labelRowName.text = (lastNameFirstName.substring(0, 14) + '...')
else
  $.labelRowName.text = lastNameFirstName



$.labelRowPhoneIcon.addEventListener "click", (e) ->
  dialog = Ti.UI.createAlertDialog(
    cancel: 1
    buttonNames: [
      "Call"
      "Cancel"
    ]
    message: "Call " + (args.first + " " + args.last) + "?"
    title: "Call"
  )
  dialog.show()
  dialog.addEventListener "click", (e) ->
    if e.index == 0
      Ti.Platform.openURL('tel:+1' + args.phone1.replace("-", ""))

$.labelRowPhone.addEventListener "click", (e) ->
  dialog = Ti.UI.createAlertDialog(
    cancel: 1
    buttonNames: [
      "Call"
      "Cancel"
    ]
    message: "Call " + (args.first + " " + args.last) + "?"
    title: "Call"
  )
  dialog.show()
  dialog.addEventListener "click", (e) ->
    if e.index == 0
      Ti.Platform.openURL('tel:+1' + args.phone1.replace("-", ""))
  
  
$.labelRowName.addEventListener "click", (e) -> 
  $.labelRowDirectionsIcon.fireEvent 'click'
  
  
$.labelRowDirectionsIcon.addEventListener "click", (e) -> 
  Ti.API.info args
  if OS_IOS
    adr = args.address.replace(" ", "+") + "+" + args.city + "+" + args.state + "+" + args.zip
    Ti.Platform.openURL("https://maps.apple.com?saddr=Current+Location&daddr=" + adr)
  else if OS_ANDROID
    Ti.Platform.openURL('http://maps.google.com/maps?saddr=Current+Location&daddr=' + adr);