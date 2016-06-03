args = arguments[0]

$.annotation.setTitle args.title
$.annotation.setLatitude args.latitude
$.annotation.setLongitude args.longitude

if OS_IOS
  $.annotation.setImage args.image
  $.annotation.setRightButton args.rightButton
else
  $.annotation.setPincolor args.pincolor

#This is the annotation id which we use to map the data with the pins
$.annotation.annoId = args.annoId