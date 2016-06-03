geo = require("../geo")
$.button.addEventListener "click", (e) ->
  $.textField.blur()
  geo.forwardGeocode $.textField.value, (geodata) ->
    $.trigger "addAnnotation",
      geodata: geodata
