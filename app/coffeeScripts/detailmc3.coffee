tableData = []
data = [
  "Alex Lopez - Misting system"
  "System status: Not connented"
  "Tank Level:97.5%"
  "Last Mist : 8/26/2013"
  "Next Mist: 8:00pm"
  "Last Refilled : 0"
  "System Type : Gen 3+"
  "Phone :9974259909"
]
i = 0

while i < data.length
  color = undefined
  if i % 2 is 1
    color = "white"
  else
    color = "#ccc"
  row = Ti.UI.createTableViewRow(
    #className: "forumEvent" # used to improve table performance
    selectedBackgroundColor: "white"
    rowIndex: i # custom property, useful for determining the row during events
    height: "30dp"
    backgroundColor: color
  )
  labelUserName = Ti.UI.createLabel(
    color: "black"
    font:
      fontSize: '14sp'
      fontWeight: "bold"

    text: data[i]
    left: '20dp'
    
    #textAlign : Ti.UI.a
    width: '200dp'
    height: '30dp'
  )
  row.add labelUserName
  tableData.push row
  i++
$.sample.data = tableData
$.mistView.addEventListener "touchstart", (e) ->
  $.mistView.backgroundColor = "white"
  return

$.mistView.addEventListener "touchend", (e) ->
  $.mistView.backgroundColor = "#ccc"
  $.mc3d.close()
  return

$.stopVieww.addEventListener "touchstart", (e) ->
  $.stopVieww.backgroundColor = "white"
  return

$.stopVieww.addEventListener "touchend", (e) ->
  $.stopVieww.backgroundColor = "#ccc"
  alert "you clicked STOP"
  return

$.skipView.addEventListener "touchstart", (e) ->
  $.skipView.backgroundColor = "white"
  return

$.skipView.addEventListener "touchend", (e) ->
  $.skipView.backgroundColor = "#ccc"
  alert "you clicked SKIP"
  return

$.clearError.addEventListener "touchstart", (e) ->
  $.clearError.backgroundColor = "white"
  return

$.clearError.addEventListener "touchend", (e) ->
  $.clearError.backgroundColor = "#ccc"
  alert "you clicked CLEAR ERROR"
  return

$.chargeView.addEventListener "touchstart", (e) ->
  $.chargeView.backgroundColor = "white"
  return

$.chargeView.addEventListener "touchend", (e) ->
  $.chargeView.backgroundColor = "#ccc"
  alert "you clicked CHARGER"
  return

$.inspectView.addEventListener "touchstart", (e) ->
  $.inspectView.backgroundColor = "white"
  return

$.inspectView.addEventListener "touchend", (e) ->
  $.inspectView.backgroundColor = "#ccc"
  alert "you clicked INSPECT"
  return
