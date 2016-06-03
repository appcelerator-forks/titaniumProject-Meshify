args = arguments[0] or {}
set = require('buttonSetLib')
ref = require('nodeRefresh')

deviceName = "mc13z"

Ti.API.info args.problems

#if tab exists, then go there
try
  $.MAScrollView.scrollToView(args.tab) 
catch e
  Ti.API.info e


if OS_IOS
  $.ptr3.init($.table)

PullLoad = (e) ->
  ref.refNode(args, args.macaddress, args.node.NodeId, $.MAScrollView.getCurrentPage())
  if e
    e.hide()

$.MAScrollView.pullLoad = PullLoad

refresh = ->
  ref.refNode(args, args.macaddress, args.node.NodeId, $.MAScrollView.getCurrentPage())
  return

#this section determines the status message and its color
##########################################################################


if args.nodecolors.statuscolor == "GREEN"
  colorPng = "/images/mistaway/ok.png"
else if args.nodecolors.statuscolor == "RED"
  colorPng = "/images/mistaway/error.png"
else if args.nodecolors.statuscolor == "YELLOW"
  colorPng = "/images/mistaway/caution.png"
else if args.nodecolors.statuscolor == "BLUE"
  colorPng = "/images/mistaway/ok.png"
else 
  colorPng = "/images/mistaway/ok.png"



#default Green Color for Status
ss = ""

if args.channels[(deviceName + ".LVL")].value < 20
  ss = "Low Tank Level"
  

error = undefined
_i = undefined
_len = undefined
_i = 0
_len = args.problems.length

while _i < _len
  error = args.problems[_i]
  ss = "Not Connected"  if error.priorityorder is 1 or error.priorityorder is 2
  _i++

if args.channels[(deviceName + ".SS")].value == "OK" and ss == "Low Tank Level"
  #yellow
  color = "caution.png"

  
#if ss in not blank then update the system status
if ss != ""
  args.channels[(deviceName + ".SS")].value = ss

#this Section handles all of the buttons for sets to the systems
###############################################################################
$.MAScrollView.addEventListener "click", (e) ->
  try
    if e.source.titleid.split(',')[0] == "1"
      name = (deviceName + "." + e.source.titleid.split(',')[1])
      value = e.source.titleid.split(',')[2]
      set.setButton(args.channels[name].channelId, args.channels[name].techName, name, args.macaddress, value, refresh)
      #ref.refNode(args, args.macaddress, args.node.NodeId, $.MAScrollView.getCurrentPage())
    else if e.source.titleid.split(',')[0] == "2"
      gotoMode()
    else if e.source.titleid.split(',')[0] == "3"
      Ti.App.fireEvent 'changeMainView', {
        view : 'contactView'
      }
  catch e
    return

$.MAScrollView.addEventListener "touchstart", (e) ->
  try
    if e.source.titleid.split(',')[0] > 0
      e.source.backgroundColor = "#4682B4"
  catch e
    return

$.MAScrollView.addEventListener "touchend", (e) ->
  try
    if e.source.titleid.split(',')[0] > 0
      Ti.API.info e.source.titleid
      e.source.backgroundColor = "#F0F8FF" 
  catch e
    return
###############################################################################
    
  
#popup mode menu  
###############################################################################  

$.savebtn.addEventListener "click", (e) ->
  $.modeList.getSelectedRow(0).title
  value = $.modeList.getSelectedRow(0).title.toString()
  Ti.API.info value
  if value == "OFF"
    value = "0"
  else if value == "REM ONLY"
    value = "1"
  else if value == "AUTO EVERYDAY"
    value = "2"
  else if value == "AUTO CUSTOM"
    value = "3"
  name = (deviceName + ".MD")
  set.setButton(args.channels[name].channelId, args.channels[name].techName, name, args.macaddress, value, refresh)
  exitMode()
$.closebtn.addEventListener "click", (e) ->
  $.modeList.setSelectedRow(0, parseInt(args.channels[(deviceName + ".MD")].value), false)
  exitMode()
$.modeList.setSelectedRow(0, parseInt(args.channels[(deviceName + ".MD")].value), false)

mode = parseInt(args.channels[(deviceName + ".MD")].value)
if mode == 0
  modetxt = "MODE: OFF"
else if mode == 1
  modetxt = "MODE: REM ONLY"
else if mode == 2
  modetxt = "MODE: AUTO EVERYDAY"
else if mode == 3
  modetxt = "MODE: AUTO CUSTOM"



  
gotoMode = ->
  $.infoList.show() 
  
 
  
  $.infoList.animate(
    top: '50%'
    curve : Ti.UI.ANIMATION_CURVE_EASE_OUT
    duration: 500
  )
exitMode = ->
  
  $.infoList.animate(
    top: '100%'
    curve : Ti.UI.ANIMATION_CURVE_EASE_OUT
    duration: 500
  )
############################################################################### 


#problems on page 3  
###############################################################################

addProblem = (txt, color, top) ->


  label1 = Ti.UI.createLabel(
    width: Ti.UI.SIZE
    height: Ti.UI.SIZE
    color: color
    font:
      fontSize: '16sp'
      fontFamily : 'BebasNeue',
      fontWeight : 'bold'
    text: txt
    left: "60dp",
    top: (top + "dp"),
    horizontalWrap : false,
    minimumFontSize:'12sp',
    textAlign: Ti.UI.TEXT_ALIGNMENT_LEFT
  )
  $.statusRow3.add label1

top = 15  

if args.problems.length > 0
  for problem in args.problems
    top += 20
    if problem.level == "RED"
      addProblem(problem.message, "red", top.toString()) 
    else if problem.level == "YELLOW"
      addProblem(problem.message, "#e9e657", top.toString())
    else if problem.level == "BLUE"
      addProblem(problem.message, "blue", top.toString()) 

$.statusImage3.top = (($.statusSection3.getHeight() / 2) - 25)




############################################################################### 






#this section does transforms on data for the mobile only views
##########################################################################

if args.channels[(deviceName + ".signal")].value is 0
  args.channels[(deviceName + ".signal")].value = "Not Connected"
else if args.channels[(deviceName + ".signal")].value <= 70
  args.channels[(deviceName + ".signal")].value = "Excellent"
else if args.channels[(deviceName + ".signal")].value >= 71 and args.channels[(deviceName + ".signal")].value <= 89
  args.channels[(deviceName + ".signal")].value = "Good"
else
  args.channels[(deviceName + ".signal")].value = "Marginal"  

if args.channels[(deviceName + ".LVL")].value > 20
  args.channels[(deviceName + ".LVL")].value = "LOW" 
else
  args.channels[(deviceName + ".LVL")].value = "OK"


##########################################################################


#insert values into template  page 1
###############################################################################
$.modeLabel.text = modetxt
$.vanityName.text = args.node.vanityname
$.statusImage.backgroundImage = colorPng
$.statusLabel.text = args.channels[(deviceName + ".SS")].value

try
  $.logo.image = args.person.CompanyObj.mobileLogoUrl
catch e
  Ti.API.info e
#Ti.API.info args
#insert values into template  page 2
###############################################################################

#$.modeLabel2.text = modetxt
#$.vanityName2.text = args.node.vanityname


#insert values into template  page 3
###############################################################################

$.systemMode3.text = modetxt
$.tankLevel3.text = args.channels[(deviceName + ".LVL")].value


$.vanityName3.text = args.node.vanityname

$.systemStatus3.text = args.channels[(deviceName + ".SS")].value
$.statusImage3.image = colorPng

$.lastMist3.text = args.channels[(deviceName + ".LM")].timestamp
$.nextMist3.text = args.channels[(deviceName + ".NSM")].value
$.lastComm3.text = args.channels[(deviceName + ".last_com")].value
$.signal3.text = args.channels[(deviceName + ".signal")].value 

