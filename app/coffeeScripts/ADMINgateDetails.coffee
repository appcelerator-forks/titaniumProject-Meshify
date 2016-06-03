args = arguments[0] or {}

set = require('buttonSetLib')


$.openGate.addEventListener "click", (e) ->
  Ti.API.info args.channels[e.source.titleid]
  set.setButton(args.channels[e.source.titleid].channelId, args.channels[e.source.titleid].techName, e.source.titleid, args.macaddress, "On")
