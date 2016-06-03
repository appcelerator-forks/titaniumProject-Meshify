#If the username and passowrd are saved, put stored values into the username and password fields
savedUsername = null
savedPassword = null
rememberButtonState = null

#This method refreshes the login page fields. If the user has just log out the fields are going to be empty, otherwise it will show the remembered value
$.wrapper.clearFields = () ->
  savedUsername = Ti.App.Properties.getString('username')
  savedPassword = Ti.App.Properties.getString('password')
  rememberButtonState = Ti.App.Properties.getBool('rememberState')
  
  #Ti.API.info '>>>>>>>>clearFields savedUsername: ' + savedUsername + '\nsavedPassword: ' + savedPassword + '\nrememberButtonState: ' + rememberButtonState
  
  if rememberButtonState is true
    #Ti.API.info '>>>>>>>>>>>>remember true'
    $.basicSwitch.setValue true
    if savedUsername
      $.username.setValue savedUsername
    if savedPassword
      $.password.setValue savedPassword
  else
    #Ti.API.info '>>>>>>>>>>>>rememer false'
    $.basicSwitch.setValue false
    $.username.setValue ''
    $.password.setValue ''
  
  #Ti.API.info '>>>>>>>>>>>>LOGIN BEFORE \n$.basicSwitch.getValue(): ' + $.basicSwitch.getValue() + '\nsavedUsername: ' + savedUsername + '\nsavedPassword: ' + savedPassword
  
  if OS_ANDROID and $.basicSwitch.getValue() and savedUsername and savedPassword
    Ti.App.fireEvent 'login'
  
  
#When return key is pressed on the keyboard, the password field will gain focus
$.username.addEventListener "return", (e) ->
  $.password.focus()

#When return key is pressed on the keyboard, the login event will be fired
$.password.addEventListener "return", (e) ->
  Ti.App.fireEvent("login")

#When the switch state is changed we save the state for later use
$.basicSwitch.addEventListener "click", (e) ->
  Ti.App.Properties.setBool 'rememberState', e.source.value

#When return key is pressed on the keyboard, the login event will be fired
$.loginButton.addEventListener "click", (e) ->
  Ti.App.fireEvent("login")

#Input text for forgot password for Android
if OS_ANDROID
  input_text = Ti.UI.createTextField(
    width: 250 
    height: 60
    borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED
    color: '#336699'
  )

$.forgotPassword.addEventListener "click", (e) -> 
  if OS_IOS
    dialog = Ti.UI.createAlertDialog(
      title: "Enter Email Address"
      style: Ti.UI.iPhone.AlertDialogStyle.PLAIN_TEXT_INPUT
      buttonNames: ["Cancel", "Reset Password"]
    )
    dialog.addEventListener "click", (e) ->
      Ti.API.info "e.text: " + e.text
      if e.index is 1
        passwordReset(e.text)
      return
    dialog.show()
  else if OS_ANDROID
    if $.username.getValue()
      input_text.setValue $.username.getValue()
    dialog = Ti.UI.createOptionDialog(
      title: "Enter Email Address"
      androidView: input_text
      buttonNames: ["Cancel", "Reset Password"]
      )
    dialog.addEventListener "click", (e) ->
      # we read it only if get it is pressed
      if e.index is 1
        passwordReset(input_text.getValue())  
      return
    dialog.show()

Ti.App.addEventListener "login", (e) ->
  
  if Titanium.Network.networkType is Titanium.Network.NETWORK_NONE
    Alloy.Globals.dialogs.confirm({
      title: "WARNING!"
      message: "Your device is not online."
      buttonNames: ["OK"]
    })
  else
    Alloy.Globals.showIndicator($.wrapper, 'loginPage')
    xhr = Titanium.Network.createHTTPClient()
    xhr.open "POST", (Alloy.Globals.rootURL + "/api/authentication/login")
    xhr.setRequestHeader "dataType", "json"
    xhr.setRequestHeader "content-type", "application/json"
    
    #Ti.API.info '>>>>>>>>>>>>>>$.username.value: ' + $.username.value + '\n$.password.value: ' + $.password.value + '\n$.basicSwitch.getValue(): ' + $.basicSwitch.getValue() 
    
    param =
      UserName: $.username.value
      Password: $.password.value
      RememberMe: $.basicSwitch.getValue()
      AppType: "mobile"
      AppVersion: "2.0.0.0"
      AppKey: "mistaway_ios"
      
    Ti.API.info 'Params: ' + JSON.stringify(param)
    xhr.send JSON.stringify(param)
    
    xhr.onload = (e) ->
      Ti.API.info "RAW =" + @responseText
      try
        data = JSON.parse(@responseText)
      catch e
        alert "Network Error, please try again"
        Alloy.Globals.hideIndicator($.wrapper, 'loginPage')
        return
      
      if @status == 200
        Ti.API.info 'data.IsAuthenticated' + data.IsAuthenticated
        if data.IsAuthenticated is false
          Alloy.Globals.hideIndicator($.wrapper, 'loginPage')
          alert data.statusMsg
          return
        else
          if $.basicSwitch.getValue()
            storeUserAndPass()
          #log event with flurry
          Alloy.Globals.flurry.setUserID $.username.getValue()
          Alloy.Globals.flurry.logEvent "login",
            username: $.username.getValue()
          
          Alloy.Globals.UserData = data
          Ti.App.Properties.setString("UserData", JSON.stringify(data))
          Alloy.Globals.UserRole = data.roles
          Ti.App.Properties.setString("UserRole", JSON.stringify(data.roles))
          
          Alloy.Globals.hideIndicator($.wrapper, 'loginPage')
          
          Ti.App.fireEvent('changeIndexView', {
            view : 'mainView'  
          })
            
          Ti.API.info "got my response, http status code " + @status
        
        if @readyState is 4
          response = JSON.parse(@responseText)
          Ti.API.info "Response = " + JSON.stringify response
        else
          alert "HTTP Ready State != 4"
      else
        Alloy.Globals.hideIndicator($.wrapper, 'loginPage')
        alert "HTTp Error Response Status Code = " + @status
        Ti.API.error "Error =>" + @response
    
    xhr.onerror = (e) ->
      if OS_IOS
        Alloy.Globals.flurry.logError "Login", "http error"
      else
        Alloy.Globals.flurry.onError "Login", "http error", ''
      
      Alloy.Globals.hideIndicator($.wrapper, 'loginPage')
      alert "there was an error, please try again"
      Ti.API.error "Bad Server =>" + e.error
  

passwordReset = (email) ->
  
  Alloy.Globals.showIndicator($.wrapper, 'loginPage')
  url = Alloy.Globals.rootURL + "/api/authentication/sendReset"
  
  client2 = Ti.Network.createHTTPClient(
  
    # function called when the response data is available
    onload: (e) ->
      Alloy.Globals.hideIndicator($.wrapper, 'loginPage')
      Ti.API.info 'e: ' + JSON.stringify e
      if e.success is true
        alert "Check you inbox for instructions on how to retrieve your password"     
      else
        alert "Error Reseting Password, Please Try Again" 
      return
    
    # function called when an error occurs, including a timeout
    onerror: (e) ->
      Alloy.Globals.hideIndicator($.wrapper, 'loginPage')
      Ti.API.info e
      alert "Error Reseting Password, Please Try Again" 
      
    timeout: 35000 # in milliseconds
  )
  
  # Prepare the connection.
  client2.open "POST", url
  sendData = {
    UserName: email
    } 
  Ti.API.info sendData
  # Send the request
  client2.send(sendData) 
  

#PRIVATE METHODS

#store the username and password
storeUserAndPass = ->
  #Ti.API.info 'username value for properties ' + $.username.getValue()
  #Ti.API.info 'password value for properties ' + $.password.getValue()
  if $.username.getValue()
    Ti.App.Properties.setString('username', $.username.getValue())
  if $.password.getValue()
    Ti.App.Properties.setString('password', $.password.getValue())
  if $.basicSwitch.getValue()
    Ti.App.Properties.setBool 'rememberState', true