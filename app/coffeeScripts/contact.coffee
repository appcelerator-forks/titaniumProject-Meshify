dataForRequest = null
reasonListValue = ''

#popup List menu  
###############################################################################  
$.clickBtn.addEventListener "click", (e) ->
  gotoList()

$.donebtn.addEventListener "click", (e) ->
  $.clickBtn.title = $.reasonList.getSelectedRow(0).title
  exitList()

gotoList = ->
  $.infoList.show() 
    
  $.infoList.animate(
    top: '50%'
    curve : Ti.UI.ANIMATION_CURVE_EASE_OUT
    duration: 500
  )
  
exitList = ->
  $.infoList.animate(
    top: '100%'
    curve : Ti.UI.ANIMATION_CURVE_EASE_OUT
    duration: 500
  )

#close keyboard 
############################################################################### 

Ti.App.addEventListener "blurContact", (e) ->
  $.nameText.blur()
  $.emailText.blur()
  $.phoneText.blur()
  $.messageText.blur()
  
  
$.contactMeView.addEventListener "click", (e) ->
  if e.source != $.nameText and e.source != $.emailText and e.source != $.phoneText and e.source != $.messageText
    $.nameText.blur()
    $.emailText.blur()
    $.phoneText.blur()
    $.messageText.blur()


#send email 
############################################################################### 
$.submitbtn.addEventListener "click", (e) ->
  generateData()
  
  url = "https://sendgrid.com/api/mail.send.json"
  
  client = Ti.Network.createHTTPClient(
  
    # function called when the response data is available
    onload: (e) ->
      try
        data = JSON.parse(@responseText)
      catch e
        Ti.API.info e
        Alloy.Globals.hideIndicator()
        alert "Error Sending Data, Please Try Again"
        return
      Ti.API.info data
      if data.message == "success"
        alert "Your authorized dealer will be contacting you shortly about your request"
      else
        alert "Network Error, Please Try Again"
      Alloy.Globals.hideIndicator()
      
      return
    # function called when an error occurs, including a timeout
    onerror: (e) ->
      Ti.API.info '222222' + e.error
      Alloy.Globals.hideIndicator()
      alert "Network Error, Please Try Again" 
      
  
    timeout: 35000 # in milliseconds
  )
  
  # Prepare the connection.
  client.open "GET", url
  client.setRequestHeader "content-type", "multipart/form-data"
    
  #sendData = encodeURIComponent(JSON.stringify(data))
  #Ti.API.info sendData
  client.send(dataForRequest)
  
generateData = () ->
  if $.reasonList.getSelectedRow(0) and $.reasonList.getSelectedRow(0).title 
    reasonListValue = $.reasonList.getSelectedRow(0).title
  else
    reasonListValue = ''
  Ti.API.info '$.reasonList.getValue(): ' + reasonListValue + '\n$.messageText.value: ' + $.messageText.value + '\nAlloy.Globals.customCompnay.line5: ' + Alloy.Globals.customCompnay.line5 + '\nAlloy.Globals.UserData.person.CompanyObj.name: ' + Alloy.Globals.UserData.person.CompanyObj.name + '\n$.nameText.value: ' + $.nameText.value + '\n$.phoneText.value: ' + $.phoneText.value + '\n$.emailText.value: ' + $.emailText.value + '\n$.messageText.value: ' + $.messageText.value

  dataForRequest = { 
    "api_user": "dane@houselynx.com" 
    "api_key": "Z!gBMeshify" 
    "to": Alloy.Globals.customCompnay.line5
    "toname": Alloy.Globals.UserData.person.CompanyObj.name
    "subject": ($.nameText.value + " has sent you a message from the iMistAway Mobile App")
    "text": ("Customer: " + $.nameText.value  + " \n" + "Phone: " + $.phoneText.value + "\n" + "Email: " + $.emailText.value + "\n \n Needs help with: " + reasonListValue + "\n \n And has included the following message: \n\n" + $.messageText.value) 
    "from": $.emailText.value
  }
  #Ti.API.info 'data: ' + JSON.stringify data 
  
Ti.App.addEventListener "setCompanyData", (e) ->
  $.title.text = Alloy.Globals.customCompnay.line1
  $.subtitle1.text = Alloy.Globals.customCompnay.line2
  $.subtitle2.text = Alloy.Globals.customCompnay.line3
  $.subtitle3.text = Alloy.Globals.customCompnay.line4
  #$.subtitle4.text = Alloy.Globals.customCompnay.line5
  Ti.API.info 'Alloy.Globals.customCompnay.line5: ' + Alloy.Globals.customCompnay.line5
  $.image.image = Alloy.Globals.UserData.person.CompanyObj.mobileLogoUrl

  $.nameText.value = Alloy.Globals.UserData.person.first + " " + Alloy.Globals.UserData.person.last
  $.emailText.value = Alloy.Globals.UserData.person.UserObj.Username
  $.phoneText.value = Alloy.Globals.UserData.person.phone1
  #generateData()
  